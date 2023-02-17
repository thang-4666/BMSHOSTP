SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0010" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BAO CAO DOI CHIEU TIEN KHACH HANG THEO NGAY
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        11-APR-2012 CREATED
-- NAMNT      31-AUG-2012 MODIFY
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_IN_DATE           DATE;
    V_F_DATE            DATE;
    V_T_DATE            DATE;
    V_BRID              VARCHAR2(4);
    V_OW_BEBAL          NUMBER;
    V_DO_BEBAL          NUMBER;
    V_FR_BEBAL          NUMBER;

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := pv_BRID;

    IF V_STROPTION = 'A' THEN
        V_STRBRID := '%%';
    ELSIF V_STROPTION = 'B' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        SELECT MAPID INTO V_STRBRID FROM BRGRP WHERE BRID = V_BRID;
    ELSIF V_STROPTION = 'S' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        V_STRBRID := V_BRID;
    ELSE
        V_STRBRID := V_BRID;
    END IF;

    -- LAY NGAY DAU KY
    V_IN_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_F_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_T_DATE := TO_DATE(T_DATE,'DD/MM/YYYY');

    -- TINH SO DU DAU KY
    -- SUA THEM TRUONG MBLOCK CHO GIAO DICH UNG TRUOC
    SELECT SUM(CASE WHEN SUBSTR(CI.custodycd,4,1) = 'P' THEN CI.BE_BALANCE ELSE 0 END) OW_BE_BAL,
        SUM(CASE WHEN SUBSTR(CI.custodycd,4,1) = 'C' THEN CI.BE_BALANCE ELSE 0 END) DO_BE_BAL,
        SUM(CASE WHEN SUBSTR(CI.custodycd,4,1) = 'F' THEN CI.BE_BALANCE ELSE 0 END) FR_BE_BAL
    INTO V_OW_BEBAL, V_DO_BEBAL, V_FR_BEBAL
    FROM
    (
    SELECT CF.custodycd, AF.ACCTNO,
        ROUND(CI.balance + CI.emkamt - nvl(TR.ci_move_from_cur,0)) + NVL(DF.BE_DFAMT,0) BE_BALANCE
    FROM CIMAST CI, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,
        (
            select tr.acctno AFAcctno,
                sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) ci_move_from_cur
            from vw_citran_gen tr
            where txtype in ('D','C')
                and field IN ('BALANCE','EMKAMT','MBLOCK') ---,'MBLOCK'
                --Bo doan rao nay de lay lai so du dau ky
                and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656','9101')
                and tr.busdate >= V_IN_DATE
            group by tr.custid, tr.custodycd, tr.acctno
            having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
        ) TR,
        (
            SELECT DF.AFACCTNO, SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) BE_DFAMT
            FROM
                (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df
                LEFT JOIN
                (
                    select tr.acctno,
                            sum (case when atx.txtype = 'D' then - tr.namt else tr.namt end) dfamt
                        from vw_dftran_all tr, apptx atx
                        where tr.txcd = atx.txcd AND atx.apptype = 'DF'
                            AND atx.txtype in ('D','C')
                            and atx.field IN ('DFBLOCKAMT','DFAMT')
                            and tr.TXDATE >= V_IN_DATE
                        group by tr.acctno
                ) TR
                ON TR.ACCTNO = DF.GROUPID
            GROUP BY DF.AFACCTNO
            HAVING SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) <>0
        ) DF
    WHERE CF.custid = AF.custid AND CI.afacctno = AF.acctno
    --AND AF.corebank = 'N'
     AND CF.custatcom = 'Y'
        AND (SUBSTR(AF.ACCTNO,1,4) LIKE V_STRBRID OR INSTR(V_STRBRID,SUBSTR(AF.ACCTNO,1,4)) >0)
        AND AF.ACCTNO = TR.AFACCTNO (+)
        AND AF.ACCTNO = DF.AFACCTNO (+)
    ) CI;

    -- LAY DU LIEU CHUNG KHOAN
    OPEN PV_REFCURSOR FOR
        SELECT CI.transtype, CI.TRANSSUBTYPE, CI.CUSTBANK, MAX(CI.BANKNAME) BANKNAME, TO_CHAR(CI.TXDATE,'DD/MM/YYYY') TXDATE,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'P' AND CI.TXTYPE = 'C' THEN CI.NAMT ELSE 0 END) OW_CRAMT,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'P' AND CI.TXTYPE = 'D' THEN CI.NAMT ELSE 0 END) OW_DRAMT,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'C' AND CI.TXTYPE = 'C' THEN CI.NAMT ELSE 0 END) DO_CRAMT,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'C' AND CI.TXTYPE = 'D' THEN CI.NAMT ELSE 0 END) DO_DRAMT,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CI.TXTYPE = 'C' THEN CI.NAMT ELSE 0 END) FR_CRAMT,
            SUM(CASE WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CI.TXTYPE = 'D' THEN CI.NAMT ELSE 0 END) FR_DRAMT,
            V_OW_BEBAL OW_BE_BAL, V_DO_BEBAL DO_BE_BAL, V_FR_BEBAL FR_BE_BAL

        FROM CFMAST CF, AFMAST AF, TLTX TL,
            (
            -- GD TIEN MAT CO QUA NGAN HANG
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                NVL(TLFLD.cvalue,'----') CUSTBANK, NVL(BN.fullname,'----') BANKNAME, 1 transtype,
                CASE WHEN CI.TLTXCD IN ('1140','1131','1132','1107','1100','1136') THEN 11
                     WHEN CI.TLTXCD IN ('1141','1101','1108','1111') THEN 12
                     WHEN CI.TLTXCD IN ('1114') THEN 13
                     WHEN CI.TLTXCD IN ('1120','1130','1134') THEN 14
                     WHEN CI.TLTXCD IN ('1162') THEN 15
                     WHEN CI.TLTXCD IN ('1139') THEN 16 END TRANSSUBTYPE
            FROM
                (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci,
                (SELECT * FROM vw_tllogfld_all /*WHERE TXDATE = V_IN_DATE*/) TLFLD, banknostro BN
            WHERE ci.tltxcd IN ('1131','1132','1141','1136')
                AND ci.field = 'BALANCE'
                AND TLFLD.TXDATE = CI.TXDATE
                AND TLFLD.TXNUM = CI.TXNUM
                AND TLFLD.fldcd = '02'
                AND TLFLD.cvalue = BN.shortname
            UNION ALL
            -- GD TIEN MAT KO QUA NGAN HANG
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                '----' CUSTBANK, '----' BANKNAME, 1 transtype,
                CASE WHEN CI.TLTXCD IN ('1140','1131','1132','1107','1100','1136') THEN 11
                     WHEN CI.TLTXCD IN ('1141','1101','1108','1111') THEN 12
                     WHEN CI.TLTXCD IN ('1114') THEN 13
                     WHEN CI.TLTXCD IN ('1120','1130','1134') THEN 14
                     WHEN CI.TLTXCD IN ('1162') THEN 15
                     WHEN CI.TLTXCD IN ('1139') THEN 16 END TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
            WHERE ci.tltxcd IN ('1140','1107','1100','1101','1139','1108','1120','1130','1162','1111','1134','1114')
            --    AND ci.txdate = '30-apr-2012'
                AND ci.field = 'BALANCE'
            UNION ALL
            -- GD LUU KY
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                '----' CUSTBANK, '----' BANKNAME, 2 transtype,
                CASE WHEN CI.TLTXCD IN ('1180','1182') THEN 21
                     WHEN CI.TLTXCD IN ('0088') THEN 22
                     WHEN CI.TLTXCD IN ('3350') AND CI.TXTYPE = 'D' THEN 23
                     WHEN CI.TLTXCD IN ('3350','3354') AND CI.TXTYPE = 'C' THEN 24 END TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
            WHERE ci.tltxcd IN ('1180','1182','0088','3350','3350','3354')
            --    AND ci.txdate = '30-apr-2012'
                AND ci.field = 'BALANCE'
            UNION ALL
            -- GD QUYEN MUA
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                '----' CUSTBANK, '----' BANKNAME, 3 transtype,
                CASE WHEN CI.TLTXCD IN ('3384','3394') THEN 31
                     WHEN CI.TLTXCD IN ('3386') THEN 32 END TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
            WHERE ci.tltxcd IN ('3384','3394','3386')
            --    AND ci.txdate = '30-apr-2012'
                AND ci.field = 'BALANCE'
            UNION ALL
            -- GD LENH
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, decode(ci.tltxcd,'8865','D',ci.txtype) txtype,
                '----' CUSTBANK, '----' BANKNAME, 4 transtype,
                CASE --WHEN CI.TLTXCD IN ('8865') THEN 41 -- tien mua T0
                     --WHEN CI.TLTXCD IN ('8889') THEN 42 -- Tien mua tra cham T2
--                     WHEN CI.TLTXCD IN ('8855') THEN 43
                     WHEN CI.TLTXCD IN ('8866') THEN 44
                     WHEN CI.TLTXCD IN ('8856') THEN 45
                     WHEN CI.TLTXCD IN ('0066') AND CI.TXCD = '0011' THEN 46
                     WHEN CI.TLTXCD IN ('0066') AND CI.TXCD = '0028' THEN 47 END TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
                  WHERE ci.tltxcd IN ('8866','8856','0066') --'8855','8865',
            --  AND ci.txdate = '30-apr-2012'
                AND ci.field = 'BALANCE'
            UNION ALL
            -- PHI MUA 8855
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, decode(ci.tltxcd,'8865','D',ci.txtype) txtype,
                '----' CUSTBANK, '----' BANKNAME, 4 transtype,
                43 TRANSSUBTYPE
            FROM (SELECT * FROM VW_CITRAN_GEN WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) CI
                  WHERE CI.TLTXCD ='8855' AND ci.field = 'BALANCE'
             UNION ALL
           -- GD GIAO TIEN MUA 8865
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, 'D' txtype,
                '----' CUSTBANK, '----' BANKNAME, 4 transtype,
                 41  TRANSSUBTYPE --tien mua T0
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
                  WHERE ci.tltxcd  IN ('8865','8889')
                  AND ci.field = 'BALANCE'
            UNION ALL

            SELECT ci.acctno, '1153' tltxcd, V_F_DATE txdate , ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 5 transtype,
                CASE WHEN CI.txcd = '0012' THEN 51
                     WHEN CI.txcd = '0011' THEN 52 END TRANSSUBTYPE
            FROM
                (
                SELECT ci.acctno, ci.txdate, ci.txnum, '0012' txcd, ci.AMT+CI.feeamt namt, 'BALANCE' field, 'C' txtype, CI.ADTYPE
                FROM (SELECT * FROM vw_adschd_all WHERE TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE) ci
                WHERE ci.deltd = 'N'
                UNION ALL
                SELECT ci.acctno, ci.txdate, ci.txnum, '0011' txcd, ci.feeamt namt, 'BALANCE' field, 'D' txtype, CI.ADTYPE
                FROM (SELECT * FROM vw_adschd_all WHERE TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE) ci
                WHERE ci.deltd = 'N'
                ) CI, ADTYPE AD, CFMAST CF
            WHERE CI.ADTYPE = AD.actype AND AD.custbank = CF.custid (+)
            UNION ALL
            -- GD HOAN TRA UNG TRUOC
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                '----' CUSTBANK, '----' BANKNAME, 5 transtype, 53 TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
            WHERE ci.tltxcd IN ('8851')
            --    AND ci.txdate = '30-apr-2012'
                AND ci.field = 'BALANCE'
            UNION ALL
           /*
            -- GD VAY BAO LANH
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 6 transtype,
                CASE WHEN CI.TLTXCD = '5566' THEN 61
                     WHEN CI.TLTXCD IN ('5540','5567') AND CI.txcd = '0065' THEN 62
                     WHEN CI.TLTXCD IN ('5540','5567') AND CI.txcd = '0075' THEN 63
                     WHEN CI.TLTXCD IN ('5540','5567') AND CI.txcd = '0073' THEN 64 END TRANSSUBTYPE
            FROM
                (
                SELECT LN.trfacctno ACCTNO, '5566' TLTXCD, LNS.rlsdate TXDATE, '' TXNUM, '0012' TXCD,
                    LNS.nml+LNS.ovd+LNS.paid NAMT, 'BALANCE' FIELD, 'C' TXTYPE, LN.custbank
                FROM vw_lnmast_all LN, (SELECT * FROM vw_lnschd_all WHERE  rlsdate >=V_F_DATE AND  rlsdate<=V_T_DATE ) LNS
                WHERE LN.acctno = LNS.acctno AND LN.oprinnml+LN.oprinovd+LN.oprinpaid > 0 AND LN.FTYPE = 'AF'
                AND lns.REFTYPE ='GP'
                UNION ALL
                SELECT LN.trfacctno ACCTNO, LNT.TLTXCD, LNT.TXDATE, LNT.TXNUM, LNT.TXCD,
                    LNT.NAMT, APT.field FIELD, 'D' TXTYPE, LN.custbank
                FROM (SELECT * FROM vw_lntran_all WHERE TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE) lnt, vw_lnmast_all LN, vw_lnschd_all LNS, APPTX APT
                WHERE LNT.TLTXCD IN ('5540','5567') AND LNT.TXCD IN ('0065','0075','0073') AND lnt.namt > 0
                    AND LNT.acctref = LNS.autoid
                    AND LN.acctno = LNS.acctno AND LN.oprinnml+LN.oprinovd+LN.oprinpaid > 0 AND LN.FTYPE = 'AF'
                    AND LNT.txcd = APT.txcd AND APT.apptype = 'LN'
                    AND lns.REFTYPE ='GP'
                ) CI, CFMAST CF
            WHERE ci.custbank = CF.custid (+)

            UNION ALL
            */


            ---df+CL
            --GD GIAI NGAN
            --                    71
            SELECT ln.trfacctno ACCTNO,'5566' TLTXCD, V_F_DATE TXDATE, '' TXNUM, '0012' TXCD,


                   case when ln.ftype ='DF' then lnslog.nml + lnslog.ovd + lnslog.paid
                                            else lnslog.nml end  NAMT,
                      'BALANCE' FIELD, 'C' TXTYPE,
                    NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 7 transtype,
                    71  TRANSSUBTYPE
              FROM
                 vw_lnmast_all LN,
                (SELECT * FROM vw_lnschd_all
                --WHERE  RLSDATE >= V_F_DATE AND RLSDATE <= V_T_DATE
                ) LNS,
                 (SELECT * FROM (  SELECT * FROM LNSCHDLOG
                 UNION ALL
                 SELECT * FROM LNSCHDLOGHIST )
                 WHERE deltd='N' AND TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE
                 ) LNSLOG, cfmast cf

            WHERE LN.acctno = LNS.acctno AND lns.autoid = LNSLOG.autoid

                 and lns.reftype in ('P','GP')
                 --AND  lns.REFTYPE <>'GP'
                 and (case when ln.ftype ='DF' then
                                              0 else lnslog.paid + lnslog.intpaid +lnslog.feepaid end)  = 0
                 AND (case when ln.ftype ='DF' then lnslog.nml + lnslog.paid + lnslog.ovd
                                               else lnslog.nml end ) >0

                 AND  ln.custbank = CF.custid (+)

            UNION ALL
             -- giao dich tra goc
             --72.1
            SELECT ln.trfacctno ACCTNO,'5566' TLTXCD, V_F_DATE TXDATE, '' TXNUM, '0012' TXCD,
                    LNSLOG.paid  NAMT, 'BALANCE' FIELD, 'D' TXTYPE,
                    NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 7 transtype,
                                        72  TRANSSUBTYPE
              FROM
                 vw_lnmast_all LN,
                (SELECT * FROM vw_lnschd_all
                --WHERE  RLSDATE >= V_F_DATE AND RLSDATE <= V_T_DATE
                ) LNS,
                 (SELECT autoid, paid,txdate FROM (  SELECT * FROM LNSCHDLOG
                 UNION ALL
                 SELECT * FROM LNSCHDLOGHIST )
                 WHERE deltd='N' AND TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE
                 and paid  <> 0 ) LNSLOG, cfmast cf

            WHERE LN.acctno = LNS.acctno AND lns.autoid = LNSLOG.autoid
                 --AND  lns.REFTYPE <>'GP'
                  and lns.reftype in ('P','GP')
                 AND  ln.custbank = CF.custid (+)

             UNION ALL

             ---Sua lai doan nay: KO check trong han qua han
            --giao dich tra lai
                            --73.1
            SELECT ln.trfacctno ACCTNO,'5566' TLTXCD, V_F_DATE TXDATE, '' TXNUM, '0012' TXCD,
                    LNSLOG.intpaid  NAMT, 'BALANCE' FIELD, 'D' TXTYPE,
                    NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 7 transtype,
                                        73  TRANSSUBTYPE
              FROM
                 vw_lnmast_all LN,
                (SELECT * FROM vw_lnschd_all
                --WHERE  RLSDATE >= V_F_DATE AND RLSDATE <= V_T_DATE
                ) LNS,
                 (SELECT autoid,
                 intpaid
                  ,txdate FROM
                  (  SELECT * FROM LNSCHDLOG
                 UNION ALL
                 SELECT * FROM LNSCHDLOGHIST )
                 WHERE deltd='N' AND TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE
                 AND  intpaid > 0
                 AND abs(nml)+abs(ovd) +abs(paid) + abs(intpaid) + abs(feepaid) > 0) LNSLOG, cfmast cf

            WHERE LN.acctno = LNS.acctno AND lns.autoid = LNSLOG.autoid
                 --AND  lns.REFTYPE <>'GP'
                  and lns.reftype in ('P','GP')
                 AND  ln.custbank = CF.custid (+)


                  UNION ALL
             --Giao dich tra phi
            SELECT ln.trfacctno ACCTNO,'5566' TLTXCD, V_F_DATE TXDATE, '' TXNUM, '0012' TXCD,
                    LNSLOG.FEEINT  NAMT, 'BALANCE' FIELD, 'D' TXTYPE,
                    NVL(CF.custid,'BVSC') CUSTBANK, NVL(CF.shortname,'BVSC') BANKNAME, 7 transtype,
                                        74  TRANSSUBTYPE
              FROM
                 vw_lnmast_all LN,
                (SELECT * FROM vw_lnschd_all
                --WHERE  RLSDATE >= V_F_DATE AND RLSDATE <= V_T_DATE
                ) LNS,
                 (SELECT autoid,
                 feepaid + feeintpaid  FEEINT
                  ,txdate FROM (  SELECT * FROM LNSCHDLOG
                 UNION ALL
                 SELECT * FROM LNSCHDLOGHIST )
                 WHERE deltd='N' AND TXDATE >= V_F_DATE AND TXDATE <= V_T_DATE
                 AND feepaid + feeintpaid > 0
                 and abs(nml)+abs(ovd) +abs(paid) + abs(intpaid) + abs(feepaid) + abs(feeintpaid) > 0 ) LNSLOG, cfmast cf

            WHERE LN.acctno = LNS.acctno AND lns.autoid = LNSLOG.autoid
                 --AND  lns.REFTYPE <>'GP'
                   and lns.reftype in ('P','GP')
                 AND  ln.custbank = CF.custid (+)

            UNION ALL
            -- GD TIEN KHAC
            SELECT ci.acctno, ci.tltxcd, V_F_DATE txdate, ci.txnum, ci.txcd, ci.namt, ci.field, ci.txtype,
                '----' CUSTBANK, '----' BANKNAME, 9 transtype, 91 TRANSSUBTYPE
            FROM (SELECT * FROM vw_citran_gen WHERE BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE) ci
            WHERE ci.field  IN ( 'BALANCE','MBLOCK')
                AND NOT EXISTS(SELECT TL.TLTXCD FROM TLTX TL WHERE TL.TLTXCD = CI.TLTXCD
                                    AND TL.tltxcd IN ('1131','1132','1141','1140','1107','1100','1136','1101',
                                                    '1139','1108','1120','1130','1162',
                                                    '1180','3350','3350','3354','3394','3386','8865','8855','8889','8866','8856','0066',
                                                    '1153','8851','5566','5540','5567','2674','2646','2648','2636','2665',
                                                    '1111','1134','1144','1145','9100','6600','6690','1114','2635','2651','2653','2656',--them doan giao dich cl+df
                                                    '5565','5562','5502','2666','2664','2624','0088','3384','1182','9101'

                                                    ))
                                                    --'0088','3384','1182',
            UNION ALL
            SELECT '0001000001' acctno, '1140' tltxcd, V_F_DATE txdate, ' ' txnum, ' ' txcd, 0 namt, ' ' field, ' ' txtype,
                '----' CUSTBANK, '----' BANKNAME, 9 transtype, 91 TRANSSUBTYPE   FROM dual

            ) CI
        WHERE CF.custid = AF.custid AND AF.acctno = CI.ACCTNO AND TL.TLTXCD = CI.TLTXCD  AND CF.custatcom = 'Y'
--        AND AF.corebank = 'N'
            AND (SUBSTR(AF.ACCTNO,1,4) LIKE V_STRBRID OR INSTR(V_STRBRID,SUBSTR(AF.ACCTNO,1,4)) >0)
        GROUP BY ci.transtype, CI.TRANSSUBTYPE, CI.CUSTBANK , CI.TXDATE
        ORDER BY CI.TXDATE, ci.transtype, CI.TRANSSUBTYPE
    ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
