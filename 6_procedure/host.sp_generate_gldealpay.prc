SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_GLDEALPAY" (
       pv_txdate in VARCHAR )
       IS
BEGIN

DELETE FROM gldealpay WHERE TXDATE = TO_DATE (pv_txdate ,'DD/MM/YYYY');

INSERT INTO gldealpay (CUSTODYCD,AFACCTNO,FULLNAME,TXDATE,overduedate,lnacctno,AUTOID,RLSDATE,LOANRATE,LOANPERIOD,BE_ORGLNAMT,ORGPAIDAMT,
INTPAIDAMT,FEEPAIDAMT,LOANTYPE,custbank,BANKNAME,CUSTBANKVL,BANKSHORTNAME,BANKINTPAIDAMT,BANKFEEPAIDAMT,BANKPAIDMETHOD,lastpaid
)
 SELECT MAX(A.CUSTODYCD) CUSTODYCD, MAX(A.AFACCTNO) AFACCTNO, MAX(A.FULLNAME) FULLNAME, A.TXDATE, MAX(A.overduedate) overduedate,
            A.lnacctno, A.AUTOID, A.RLSDATE, MAX(A.LOANRATE) LOANRATE,MAX(A.LOANPERIOD) LOANPERIOD,
                MAX(A.BE_ORGLNAMT) BE_ORGLNAMT, SUM(A.ORGPAIDAMT) ORGPAIDAMT,
                SUM(A.INTPAIDAMT) INTPAIDAMT, SUM(A.FEEPAIDAMT) FEEPAIDAMT, MAX(A.LOANTYPE) LOANTYPE,
                MAX(A.custbank) custbank, MAX(A.BANKNAME) BANKNAME, MAX(A.CUSTBANKVL) CUSTBANKVL, MAX(A.BANKSHORTNAME) BANKSHORTNAME,
                SUM(A.BANKINTPAIDAMT) BANKINTPAIDAMT,
                SUM(A.BANKFEEPAIDAMT) BANKFEEPAIDAMT,
                MAX(A.BANKPAIDMETHOD) BANKPAIDMETHOD, MAX(A.lastpaid) lastpaid
        FROM
        (
            -- DF
            SELECT CF.CUSTODYCD, cf.acctno AFACCTNO, CF.FULLNAME, lnt.TXDATE, LN.overduedate, lnt.lnacctno, LN.AUTOID,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE, LN.LOANRATE, --LN.LOANPERIOD,
                to_date(pv_txdate,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                LN.prinamt + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT, NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                NVL(lnt.INTPAIDAMT,0) INTPAIDAMT, NVL(lnt.FEEPAIDAMT,0) FEEPAIDAMT, 'DF' LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN ln.custbank ELSE 'OVDB' END custbank,
                LN.CUSTBANK CUSTBANKVL, LN.BANKSHORTNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN LN.BANKNAME ELSE 'OVDB' END BANKNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) >0 OR ln.BANKPAIDMETHOD = 'I' THEN NVL(lnt.INTPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'N' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'Y' THEN LN.intpaid
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) > 0 THEN
                        fn_calc_lnintpaid(LN.AUTOID, TO_CHAR(LNT.TXDATE,'DD/MM/YYYY'), LNT.LNTAUTOID, 'DF')
                    ELSE 0 END BANKINTPAIDAMT,
                /*CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN NVL(lnt.FEEPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'N' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'Y' THEN LN.FEEINTPAID
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) > 0 THEN
                        fn_calc_lnfeepaid(LN.AUTOID, TO_CHAR(LNT.TXDATE,'DD/MM/YYYY'), LNT.LNTAUTOID, 'DF')
                    ELSE 0 END BANKFEEPAIDAMT,*/
                NVL(lnt.FEEPAIDAMT,0) BANKFEEPAIDAMT,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) >0 THEN 'I' ELSE ln.BANKPAIDMETHOD END BANKPAIDMETHOD, LNT.lastpaid
                --ln.custbank, ln.BANKNAME
            FROM
                (
                    SELECT max(lnt.ref) afacctno, lnt.txdate, lnt.acctno lnacctno,
                        sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                        sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                        sum(CASE WHEN lnt.txcd = '0090' THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0017','0027','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT,
                        max(lng.lastpaid) lastpaid, MAX(LNT.AUTOID) LNTAUTOID
                    FROM vw_lntran_all lnt,
                        (SELECT lng.txdate, lng.txnum, lng.autoid, max(lng.lastpaid) lastpaid, max(lns.acctno) acctno
                        from vw_lnschdlog_all lng, vw_lnschd_all lns
                        WHERE lng.autoid = lns.autoid AND lns.reftype IN ('P','GP')
                        GROUP BY lng.txdate, lng.txnum, lng.autoid) lng
                    WHERE lnt.txdate = lng.txdate AND lnt.txnum = lng.txnum AND lnt.acctno = lng.acctno
                        AND lnt.tltxcd IN ('2646','2648','2636','2665')
                        AND lnt.txdate = to_date(pv_txdate,'DD/MM/YYYY')
                    GROUP BY lnt.txdate, /*lnt.txnum,*/ lnt.acctno
                ) lnt
                INNER JOIN
                (
                    SELECT ln.acctno, ln.trfacctno, ln.rlsdate,LNS.overduedate, lns.rate2 LOANRATE, ln.prinperiod LOANPERIOD,
                        ln.prinnml + LN.prinovd prinamt, DECODE(LN.RRTYPE,'C','BVSC', NVL(LN.CUSTBANK,'')) CUSTBANK,
                        NVL(CF.FULLNAME,'BVSC') BANKNAME, NVL(CF.shortname,'BVSC') BANKSHORTNAME,
                        ln.BANKPAIDMETHOD, LNS.FEEINTPAID, LNS.intpaid, LNS.autoid
                    FROM vw_lnmast_all LN, vw_lnschd_all lns, cfmast cf
                    WHERE ln.acctno = lns.acctno AND LN.FTYPE = 'DF' AND LNS.reftype IN ('P','GP')
                        AND LN.CUSTBANK = CF.CUSTID (+)
                ) ln
                ON lnt.lnacctno = LN.acctno --AND ln.CUSTBANK LIKE V_CUSTBANK
                INNER JOIN
                (
                    SELECT CF.custodycd, AF.acctno, CF.fullname
                    FROM CFMAST CF, AFMAST AF
                    WHERE CF.custid = AF.custid

                ) CF
                ON LN.trfacctno = CF.ACCTNO
                LEFT JOIN
                (
                    SELECT lnt.acctno lnacctno, sum(lnt.namt) ORGPAIDAMT
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('2646','2648','2636','2665') AND lnt.TXCD ='0014'
                        AND lnt.txdate >= to_date(pv_txdate,'DD/MM/YYYY')
                    GROUP BY lnt.acctno
                ) PS
                ON lnt.lnacctno = PS.lnacctno
            UNION ALL
            -- KHOAN VAY DF TOI HAN
            SELECT CF.CUSTODYCD, CF.ACCTNO AFACCTNO, CF.FULLNAME, ln.overduedate  TXDATE, LN.overduedate, ln.ACCTNO lnacctno, LN.AUTOID,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE,LN.LOANRATE,
                to_date(pv_txdate,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                LN.prinamt + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT,
                LN.prinamt + NVL(PS.ORGPAIDAMT,0) - NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                --round(ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)) INTPAIDAMT,
                0 INTPAIDAMT,
                --round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)) FEEPAIDAMT,
                0 FEEPAIDAMT,
                'DF' LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN ln.custbank ELSE 'OVDB' END custbank,
                LN.CUSTBANK CUSTBANKVL, LN.BANKSHORTNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN LN.BANKNAME ELSE 'OVDB' END BANKNAME,
                round(CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND nvl(LNT.lastpaid,'N') = 'Y' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LN.prinamt + NVL(PS.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LN.prinamt + NVL(PS.ORGPAIDAMT,0) > 0 THEN round(LN.intpaid + ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0))
                    --WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' /*AND NVL(lnt.ORGPAIDAMT,0) > 0*/ THEN
                        round(ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)) +
                            CASE WHEN NVL(lnt.ORGPAIDAMT,0) >0 THEN 0
                                WHEN LN.prinamt + NVL(PS.ORGPAIDAMT,0) - NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                                ELSE fn_calc_lnintpaid(LN.autoid, TO_CHAR(LN.overduedate,'DD/MM/YYYY'), NVL(LNT.LNTAUTOID,0), 'DF') /*- NVL(lnt.INTPAIDAMT,0)*/ END
                    ELSE 0 END) BANKINTPAIDAMT,
                /*round(CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' THEN LN.FEEINTPAID + round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0))
                    WHEN ln.BANKPAIDMETHOD = 'P' THEN
                        round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)) + CASE WHEN NVL(lnt.ORGPAIDAMT,0) >0 THEN 0 ELSE fn_calc_lnfeepaid(LN.autoid, TO_CHAR(LN.overduedate,'DD/MM/YYYY'), NVL(LNT.LNTAUTOID,0), 'MR') END
                    ELSE 0 END) BANKFEEPAIDAMT,*/
                ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0) BANKFEEPAIDAMT,
                ln.BANKPAIDMETHOD, NVL(LNT.lastpaid,'N') LASTPAID
            FROM
            (
                SELECT ln.acctno, ln.trfacctno, ln.rlsdate,LNS.overduedate, lns.rate2 LOANRATE, ln.prinperiod LOANPERIOD,
                    ln.prinnml + LN.prinovd prinamt,
                    lns.intnmlacr+lns.intdue+lns.intovd remainint,
                    lns.feeintnmlacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintnml+lns.feeintovd remainfee,
                    DECODE(LN.RRTYPE,'C','BVSC', NVL(LN.CUSTBANK,'BVSC')) CUSTBANK,
                    NVL(CF.FULLNAME,'BVSC') BANKNAME, NVL(CF.shortname,'BVSC') BANKSHORTNAME,
                    ln.BANKPAIDMETHOD, LNS.FEEINTPAID, LNS.intpaid, LNS.autoid
                FROM vw_lnmast_all LN, vw_lnschd_all lns, cfmast cf
                WHERE ln.acctno = lns.acctno AND LN.FTYPE = 'DF' AND LNS.reftype IN ('P','GP')
                    AND LNS.overduedate = TO_DATE(pv_txdate,'DD/MM/YYYY')
                    AND LN.custbank IS NOT NULL AND LN.bankpaidmethod <> 'I'
                    AND LN.CUSTBANK = CF.CUSTID (+)
        /*    SELECT lns.autoid, ln.acctno, ln.trfacctno, lns.rlsdate, lns.overduedate, ln.rate2 LOANRATE, ln.prinperiod MRLOANPERIOD,
                    LN.oprinperiod GRLOANPERIOD,
                    lns.nml + lns.ovd MRprinamt, lns.nml + lns.ovd GRPRINAMT,
                    lns.intnmlacr+lns.intdue+lns.intovd+lns.intovdprin remainint,
                    lns.feeintnmlacr+lns.feeintovdacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintnml+lns.feeintovd remainfee,
                    DECODE(LN.RRTYPE,'C','BVSC', NVL(LN.CUSTBANK,'BVSC')) CUSTBANK, NVL(CF.FULLNAME,'BVSC') BANKNAME,
                    ln.BANKPAIDMETHOD, LNS.FEEINTPAID, LNS.intpaid, 'DF' LOANTYPE
                FROM vw_lnmast_all LN, vw_lnschd_all lns, cfmast cf
                WHERE ln.acctno = lns.acctno AND LN.ftype = 'DF'
                    AND LNS.overduedate = TO_DATE(pv_txdate,'DD/MM/YYYY')
                    AND LN.custbank IS NOT NULL
                    AND LNS.reftype = 'P'
                    AND LN.CUSTBANK = CF.CUSTID (+)*/

            ) ln
            INNER JOIN
            (
                SELECT CF.custodycd, AF.acctno, CF.fullname
                FROM CFMAST CF, AFMAST AF
                WHERE CF.custid = AF.custid
            ) CF
            ON LN.trfacctno = CF.ACCTNO
            LEFT JOIN
            (
                SELECT lnt.acctno lnacctno,
                    sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                                    sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                                    sum(CASE WHEN lnt.txcd = '0090' THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                    lnt.acctref lnsautoid
                FROM vw_lntran_all lnt
                WHERE lnt.tltxcd IN ('2646','2648','2636','2665') --AND lnt.TXCD IN ('0014','0065')
                    AND lnt.txdate >= to_date(pv_txdate,'DD/MM/YYYY')
                GROUP BY lnt.acctno, lnt.acctref
            ) PS
            ON ln.acctno = PS.lnacctno --AND ln.autoid = ps.lnsautoid
            LEFT JOIN
            (
                SELECT lnt.txdate, lnt.acctno lnacctno, lng.autoid lnsautoid,
                    sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                                    sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                                    sum(CASE WHEN lnt.txcd = '0090' THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                                    sum(CASE WHEN lnt.txcd IN ('0017','0027','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT,
                    max(lng.lastpaid) lastpaid, MAX(LNT.AUTOID) LNTAUTOID
                FROM vw_lntran_all lnt,
                    (SELECT lng.txdate, lng.txnum, lng.autoid, max(lng.lastpaid) lastpaid, max(lns.acctno) acctno
                        from vw_lnschdlog_all lng, vw_lnschd_all lns
                        WHERE lng.autoid = lns.autoid AND lns.reftype IN ('P','GP')
                        GROUP BY lng.txdate, lng.txnum, lng.autoid) lng
                    WHERE lnt.txdate = lng.txdate AND lnt.txnum = lng.txnum AND lnt.acctno = lng.acctno
                    AND lnt.tltxcd IN ('2646','2648','2636','2665') --AND lnt.TXCD IN ('0014','0024','0090')
                    AND lnt.txdate = to_date(pv_txdate,'DD/MM/YYYY')
                GROUP BY lnt.txdate, lnt.acctno, lng.autoid
            ) lnt
            ON LN.ACCTNO = LNT.lnacctno AND ln.autoid = lnt.lnsautoid

            UNION ALL
            -- MARGIN & BAO LANH TIEN MUA
            SELECT CF.CUSTODYCD, CF.ACCTNO AFACCTNO, CF.FULLNAME,lnt.TXDATE , LN.overduedate, lnt.lnacctno, LN.AUTOID,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE,
                DECODE(LN.LOANTYPE,'MR',LN.MRLOANRATE,LN.GRLOANRATE) LOANRATE,
                --DECODE(LNT.LOANTYPE,'MR',LN.MRLOANPERIOD,LN.GRLOANPERIOD) LOANPERIOD,
                to_date(pv_txdate,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT, NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                NVL(lnt.INTPAIDAMT,0) INTPAIDAMT, NVL(lnt.FEEPAIDAMT,0) FEEPAIDAMT, LN.LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN ln.custbank ELSE 'OVDB' END custbank,
                LN.CUSTBANK CUSTBANKVL, LN.BANKSHORTNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN LN.BANKNAME ELSE 'OVDB' END BANKNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) >0 OR ln.BANKPAIDMETHOD = 'I' THEN NVL(lnt.INTPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'N' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'Y' THEN LN.intpaid
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) > 0 THEN
                        fn_calc_lnintpaid(LNT.LNSAUTOID, TO_CHAR(LNT.TXDATE,'DD/MM/YYYY'), LNT.LNTAUTOID, 'MR')
                    ELSE 0 END BANKINTPAIDAMT,
                /*CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN NVL(lnt.FEEPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'N' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND LNT.lastpaid = 'Y' THEN LN.FEEINTPAID
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) > 0 THEN
                        fn_calc_lnfeepaid(LNT.LNSAUTOID, TO_CHAR(LNT.TXDATE,'DD/MM/YYYY'), LNT.LNTAUTOID, 'MR')
                    ELSE 0 END BANKFEEPAIDAMT,*/
                NVL(lnt.FEEPAIDAMT,0) BANKFEEPAIDAMT,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) >0 THEN 'I' ELSE ln.BANKPAIDMETHOD END BANKPAIDMETHOD, LNT.lastpaid

            FROM
                (
                    SELECT lnt.txdate, /*lnt.txnum, */lnt.acctno lnacctno, lnt.acctref lnsautoid,
                        sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0090','0073') THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                        --CASE WHEN SUM(CASE WHEN lnt.txcd IN ('0065','0075','0073') THEN lnt.namt ELSE 0 end) > 0 THEN 'GR' ELSE 'MR' END LOANTYPE,
                        SUM(CASE WHEN lnt.txcd IN ('0017','0027','0058','0060','0066','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT,
                        max(lng.lastpaid) lastpaid, MAX(LNT.AUTOID) LNTAUTOID
                    FROM vw_lntran_all lnt,
                        (SELECT lng.txdate, lng.txnum, lng.autoid, max(lng.lastpaid) lastpaid
                        from vw_lnschdlog_all lng
                        GROUP BY lng.txdate, lng.txnum, lng.autoid) lng
                    WHERE lnt.txdate = lng.txdate AND lnt.txnum = lng.txnum AND lnt.acctref = lng.autoid
                        AND lnt.tltxcd IN ('5540','5567') --AND lnt.TXCD IN ('0014','0024','0090')
                        AND lnt.txdate = to_date(pv_txdate,'DD/MM/YYYY')
                    GROUP BY lnt.txdate, /*lnt.txnum, */lnt.acctno, lnt.acctref
                ) lnt
                INNER JOIN
                (
                    SELECT lns.autoid, ln.acctno, ln.trfacctno, lns.rlsdate, LNS.overduedate, lns.rate2 MRLOANRATE, ln.prinperiod MRLOANPERIOD,
                        LN.orate2 GRLOANRATE, LN.oprinperiod GRLOANPERIOD,
                        lns.nml + lns.ovd MRprinamt, lns.nml + lns.ovd GRPRINAMT,
                        DECODE(LN.RRTYPE,'C','BVSC', NVL(LN.CUSTBANK,'BVSC')) CUSTBANK, NVL(CF.FULLNAME,'BVSC') BANKNAME,
                        ln.BANKPAIDMETHOD, LNS.FEEINTPAID, LNS.intpaid, NVL(CF.shortname,'BVSC') BANKSHORTNAME,
                        decode(lns.reftype,'P','MR','GP','GR','MR') LOANTYPE
                    FROM vw_lnmast_all LN, vw_lnschd_all lns, cfmast cf
                    WHERE ln.acctno = lns.acctno AND LN.FTYPE = 'AF' AND LNS.reftype IN ('P','GP')
                        AND LN.CUSTBANK = CF.CUSTID (+)
                ) ln
                ON lnt.lnacctno = LN.acctno AND lnt.lnsautoid = ln.autoid --AND ln.CUSTBANK LIKE V_CUSTBANK
                INNER JOIN
                (
                    SELECT CF.custodycd, AF.acctno, CF.fullname
                    FROM CFMAST CF, AFMAST AF
                    WHERE CF.custid = AF.custid
                ) CF
                ON LN.trfacctno = CF.ACCTNO
                LEFT JOIN
                (
                    SELECT lnt.acctno lnacctno, sum(lnt.namt) ORGPAIDAMT, lnt.acctref lnsautoid
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('5540','5567') AND lnt.TXCD IN ('0014','0065')
                        AND lnt.txdate >= to_date(pv_txdate,'DD/MM/YYYY')
                    GROUP BY lnt.acctno, lnt.acctref
                ) PS
                ON lnt.lnacctno = PS.lnacctno AND lnt.lnsautoid = ps.lnsautoid
            UNION ALL
            -- KHOAN VAY MR/CL TOI HAN
            SELECT CF.CUSTODYCD, CF.ACCTNO AFACCTNO, CF.FULLNAME, ln.overduedate TXDATE, LN.overduedate, ln.ACCTNO lnacctno, LN.AUTOID,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE,
                DECODE(LN.LOANTYPE,'MR',LN.MRLOANRATE,LN.GRLOANRATE) LOANRATE,
                to_date(pv_txdate,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT,
                DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) - NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                --round(ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)) INTPAIDAMT,
                0 INTPAIDAMT,
                --round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)) FEEPAIDAMT,
                0 FEEPAIDAMT,
                LN.LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN ln.custbank ELSE 'OVDB' END custbank,
                LN.CUSTBANK CUSTBANKVL, LN.BANKSHORTNAME,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 OR LN.CUSTBANK = 'BVSC' THEN LN.BANKNAME ELSE 'OVDB' END BANKNAME,
                round(CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' AND nvl(LNT.lastpaid,'N') = 'Y' THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'A' AND DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) > 0 THEN round(LN.intpaid + ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0))
                    --WHEN ln.BANKPAIDMETHOD = 'P' AND NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                    WHEN ln.BANKPAIDMETHOD = 'P' /*AND NVL(lnt.ORGPAIDAMT,0) > 0*/ THEN
                        round(ln.remainint + nvl(ps.INTPAIDAMT,0) - NVL(lnt.INTPAIDAMT,0)) +
                            CASE WHEN NVL(lnt.ORGPAIDAMT,0) >0 THEN 0
                                 WHEN DECODE(LN.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) - NVL(lnt.ORGPAIDAMT,0) = 0 THEN 0
                                 else fn_calc_lnintpaid(LN.autoid, TO_CHAR(LN.overduedate,'DD/MM/YYYY'), NVL(LNT.LNTAUTOID,0), 'MR')/* - NVL(lnt.INTPAIDAMT,0)*/ END
                    ELSE 0 END) BANKINTPAIDAMT,
                /*round(CASE WHEN ln.BANKPAIDMETHOD = 'I' THEN ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)
                    WHEN ln.BANKPAIDMETHOD = 'A' THEN LN.FEEINTPAID + round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0))
                    WHEN ln.BANKPAIDMETHOD = 'P' THEN
                        round(ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0)) + CASE WHEN NVL(lnt.ORGPAIDAMT,0) >0 THEN 0 ELSE fn_calc_lnfeepaid(LN.autoid, TO_CHAR(LN.overduedate,'DD/MM/YYYY'), NVL(LNT.LNTAUTOID,0), 'MR') END
                    ELSE 0 END) BANKFEEPAIDAMT,*/
                ln.remainfee + nvl(ps.FEEPAIDAMT,0) - NVL(lnt.FEEPAIDAMT,0) BANKFEEPAIDAMT,
                ln.BANKPAIDMETHOD, NVL(LNT.lastpaid,'N') LASTPAID
            FROM
            (
                SELECT lns.autoid, ln.acctno, ln.trfacctno, lns.rlsdate, lns.overduedate, lns.rate2 MRLOANRATE, ln.prinperiod MRLOANPERIOD,
                    LN.orate2 GRLOANRATE, LN.oprinperiod GRLOANPERIOD,
                    lns.nml + lns.ovd MRprinamt, lns.nml + lns.ovd GRPRINAMT,
                    lns.intnmlacr+lns.intdue+lns.intovd remainint,
                    lns.feeintnmlacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintnml+lns.feeintovd remainfee,
                    DECODE(LN.RRTYPE,'C','BVSC', NVL(LN.CUSTBANK,'BVSC')) CUSTBANK, NVL(CF.FULLNAME,'BVSC') BANKNAME,
                    NVL(CF.shortname,'BVSC') BANKSHORTNAME,
                    ln.BANKPAIDMETHOD, LNS.FEEINTPAID, LNS.intpaid, decode(lns.reftype,'P','MR','GP','GR','MR') LOANTYPE
                FROM vw_lnmast_all LN, vw_lnschd_all lns, cfmast cf
                WHERE ln.acctno = lns.acctno
                    AND LNS.overduedate = TO_DATE(pv_txdate,'DD/MM/YYYY')
                    AND LN.custbank IS NOT NULL AND LN.bankpaidmethod <> 'I'
                    AND LN.FTYPE = 'AF' AND LNS.reftype IN ('P','GP')
                    AND LN.CUSTBANK = CF.CUSTID (+)

            ) ln
            INNER JOIN
            (
                SELECT CF.custodycd, AF.acctno, CF.fullname
                FROM CFMAST CF, AFMAST AF
                WHERE CF.custid = AF.custid
            ) CF
            ON LN.trfacctno = CF.ACCTNO
            LEFT JOIN
            (
                SELECT lnt.acctno lnacctno,
                    sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                    sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                    sum(CASE WHEN lnt.txcd IN ('0090','0073') THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                    lnt.acctref lnsautoid
                FROM vw_lntran_all lnt
                WHERE lnt.tltxcd IN ('5540','5567') --AND lnt.TXCD IN ('0014','0065')
                    AND lnt.txdate >= to_date(pv_txdate,'DD/MM/YYYY')
                GROUP BY lnt.acctno, lnt.acctref
            ) PS
            ON ln.acctno = PS.lnacctno AND ln.autoid = ps.lnsautoid
            LEFT JOIN
            (
                SELECT lnt.txdate, lnt.acctno lnacctno, lnt.acctref lnsautoid,
                    sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                    sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                    sum(CASE WHEN lnt.txcd IN ('0090','0073') THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                    --CASE WHEN SUM(CASE WHEN lnt.txcd IN ('0065','0075','0073') THEN lnt.namt ELSE 0 end) > 0 THEN 'GR' ELSE 'MR' END LOANTYPE,
                    SUM(CASE WHEN lnt.txcd IN ('0017','0027','0058','0060','0066','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT,
                    max(lng.lastpaid) lastpaid, MAX(LNT.AUTOID) LNTAUTOID
                FROM vw_lntran_all lnt,
                    (SELECT lng.txdate, lng.txnum, lng.autoid, max(lng.lastpaid) lastpaid
                    from vw_lnschdlog_all lng
                    GROUP BY lng.txdate, lng.txnum, lng.autoid) lng
                WHERE lnt.txdate = lng.txdate AND lnt.txnum = lng.txnum AND lnt.acctref = lng.autoid
                    AND lnt.tltxcd IN ('5540','5567') --AND lnt.TXCD IN ('0014','0024','0090')
                    AND lnt.txdate = to_date(pv_txdate,'DD/MM/YYYY')
                GROUP BY lnt.txdate, lnt.acctno, lnt.acctref
            ) lnt
            ON LN.ACCTNO = LNT.lnacctno AND ln.autoid = lnt.lnsautoid
        ) A
        WHERE A.LOANTYPE LIKE '%'
            AND A.CUSTBANK LIKE '%'

            AND A.ORGPAIDAMT >=0
            /*AND CASE WHEN A.BANKPAIDMETHOD = 'I' THEN A.ORGPAIDAMT+A.BANKINTPAIDAMT+A.BANKFEEPAIDAMT
                                                ELSE A.ORGPAIDAMT END > 0*/
        GROUP BY A.TXDATE, A.LNACCTNO, A.AUTOID, A.RLSDATE
        HAVING CASE WHEN MAX(A.BANKPAIDMETHOD) = 'I' THEN SUM(A.ORGPAIDAMT+A.BANKINTPAIDAMT+A.BANKFEEPAIDAMT)
                                                ELSE SUM(A.ORGPAIDAMT) END > 0;

        COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  return;

END;

 
 
 
 
/
