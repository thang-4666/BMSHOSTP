SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN1001" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN      VARCHAR2,
   T_DATE           IN      VARCHAR2,
  -- I_DATE           IN      VARCHAR2,
   CF_DATE           IN      VARCHAR2,
   CT_DATE           IN      VARCHAR2,
   CUSTBANK         IN      VARCHAR2,
   SERVICETYPE      IN       VARCHAR2,
   SIGNTYPE         IN      VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   PV_AFTYPE        IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO THANH TOAN TIEN VAY
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        05-APR-2012 CREATED
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_CUSTBANK          varchar2(10);
    V_SVTYPE            VARCHAR2(5);
    V_IN_DATE           VARCHAR2(15);

    V_FROMDATE          DATE;
    V_TODATE            DATE;

    V_CFROMDATE         DATE;
    V_CTODATE           DATE;

    V_SIGNTYPE          VARCHAR2(10);
    V_BRID              VARCHAR2(4);
    V_CUSTODYCD       VARCHAR2(10);
    V_AFACCTNO         VARCHAR2(10);
    V_AFTYPE           VARCHAR2(10);

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

   -- V_IN_DATE := I_DATE;

    V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
    V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');

    V_CFROMDATE:=TO_DATE(CF_DATE,'DD/MM/YYYY');
    V_CTODATE:=TO_DATE(CT_DATE,'DD/MM/YYYY');


    V_SIGNTYPE := SIGNTYPE;

    IF PV_CUSTODYCD = 'ALL' OR PV_CUSTODYCD IS NULL THEN
       V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD := UPPER( PV_CUSTODYCD);
    END IF;

    IF PV_AFACCTNO = 'ALL' OR PV_AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := UPPER( PV_AFACCTNO);
    END IF;

    IF CUSTBANK = 'ALL' OR CUSTBANK IS NULL THEN
        V_CUSTBANK := '%%';
    ELSE
        V_CUSTBANK := CUSTBANK;
    END IF;

    IF SERVICETYPE = 'ALL' OR SERVICETYPE IS NULL THEN
        V_SVTYPE := '%%';
    ELSE
        V_SVTYPE := SERVICETYPE;
    END IF;

     IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      V_AFTYPE := '%%';
   ELSE
      V_AFTYPE := PV_AFTYPE;
   END IF;

    OPEN PV_REFCURSOR FOR
        SELECT A.*, V_SIGNTYPE SIGNER
        FROM
        (
            -- DF
            SELECT CF.CUSTODYCD, cf.acctno AFACCTNO, CF.FULLNAME, TO_CHAR(lnt.TXDATE,'DD/MM/YYYY') TXDATE, lnt.lnacctno,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE, LN.LOANRATE, --LN.LOANPERIOD,
                to_date(lnt.TXDATE,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                LN.prinamt + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT, NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                NVL(lnt.INTPAIDAMT,0) INTPAIDAMT, NVL(lnt.FEEPAIDAMT,0) FEEPAIDAMT, 'DF' LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 or ln.custbank = 'BMSC' THEN ln.custbank ELSE ln.custbank || '-OVDB' END custbank,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 THEN LN.BANKNAME ELSE LN.BANKNAME END BANKNAME,
                LN.BANKSHORTNAME
                --ln.custbank, ln.BANKNAME
            FROM
                (
                    SELECT max(lnt.ref) afacctno, lnt.txdate, lnt.acctno lnacctno,
                        sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                        sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                        sum(CASE WHEN lnt.txcd = '0090' THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0017','0027','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('2646','2648','2636','2665') --AND lnt.TXCD IN ('0014','0024','0090')
                        --AND lnt.txdate = to_date(V_IN_DATE,'DD/MM/YYYY')
                        AND lnt.txdate BETWEEN V_FROMDATE AND V_TODATE
                    GROUP BY lnt.txdate, lnt.txnum, lnt.acctno
                ) lnt
                INNER JOIN
                (
                    SELECT ln.acctno, ln.trfacctno, ln.rlsdate, ln.rate2 LOANRATE, ln.prinperiod LOANPERIOD,
                        ln.prinnml + LN.prinovd prinamt, DECODE(LN.RRTYPE,'C','BMSC', NVL(LN.CUSTBANK,'BMSC')) CUSTBANK,
                        NVL(CF.FULLNAME,'BMSC') BANKNAME ,NVL(CF.shortname,'BMSC') BANKSHORTNAME
                    FROM vw_lnmast_all LN, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                    WHERE LN.CUSTBANK = CF.CUSTID (+)
                  --  AND ln.rlsdate  = to_date(V_IN_DATE,'DD/MM/YYYY')
                    and ln.rlsdate between V_CFROMDATE and V_CTODATE
                ) ln
                ON lnt.lnacctno = LN.acctno --AND ln.CUSTBANK LIKE V_CUSTBANK
                INNER JOIN
                (
                    SELECT CF.custodycd, AF.acctno, CF.fullname
                    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,AFTYPE AFT
                    WHERE CF.custid = AF.custid
                    AND AF.ACCTNO LIKE V_AFACCTNO
                    AND CF.CUSTODYCD LIKE V_CUSTODYCD
                    AND AFT.ACTYPE = AF.ACTYPE
                    AND AFT.PRODUCTTYPE LIKE V_AFTYPE
                ) CF
                ON LN.trfacctno = CF.ACCTNO
                LEFT JOIN
                (
                    SELECT lnt.acctno lnacctno, sum(lnt.namt) ORGPAIDAMT
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('2646','2648','2636','2665') AND lnt.TXCD ='0014'
                       -- AND lnt.txdate >= to_date(V_IN_DATE,'DD/MM/YYYY')
                        AND lnt.txdate BETWEEN V_FROMDATE AND V_TODATE
                    GROUP BY lnt.acctno
                ) PS
                ON lnt.lnacctno = PS.lnacctno
            UNION ALL
            -- MARGIN & BAO LANH TIEN MUA
            SELECT CF.CUSTODYCD, CF.ACCTNO AFACCTNO, CF.FULLNAME, TO_CHAR(lnt.TXDATE,'DD/MM/YYYY') TXDATE, lnt.lnacctno,
                to_char(LN.RLSDATE,'DD/MM/YYYY') RLSDATE,
                DECODE(LNT.LOANTYPE,'MR',LN.MRLOANRATE,LN.GRLOANRATE) LOANRATE,
                --DECODE(LNT.LOANTYPE,'MR',LN.MRLOANPERIOD,LN.GRLOANPERIOD) LOANPERIOD,
                to_date(lnt.TXDATE,'DD/MM/YYYY') - ln.rlsdate LOANPERIOD,
                DECODE(LNT.LOANTYPE,'MR',LN.MRprinamt,LN.GRprinamt) + NVL(PS.ORGPAIDAMT,0) BE_ORGLNAMT, NVL(lnt.ORGPAIDAMT,0) ORGPAIDAMT,
                NVL(lnt.INTPAIDAMT,0) INTPAIDAMT, NVL(lnt.FEEPAIDAMT,0) FEEPAIDAMT, LNT.LOANTYPE,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 or ln.custbank = 'BMSC' THEN ln.custbank ELSE ln.custbank || '-OVDB' END custbank,
                CASE WHEN NVL(LNT.OVDPAIDAMT,0) = 0 THEN LN.BANKNAME ELSE LN.BANKNAME END BANKNAME,
                LN.BANKSHORTNAME
            FROM
                (
                    SELECT lnt.txdate, lnt.acctno lnacctno, lnt.acctref lnsautoid,
                        sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT,
                        sum(CASE WHEN lnt.txcd IN ('0090','0073') THEN lnt.namt ELSE 0 end) FEEPAIDAMT,
                        CASE WHEN SUM(CASE WHEN lnt.txcd IN ('0065','0075','0073') THEN lnt.namt ELSE 0 end) > 0 THEN 'GR' ELSE 'MR' END LOANTYPE,
                        SUM(CASE WHEN lnt.txcd IN ('0017','0027','0058','0060','0066','0083') THEN lnt.namt ELSE 0 end) OVDPAIDAMT
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('5540','5567') --AND lnt.TXCD IN ('0014','0024','0090')
                       -- AND lnt.txdate = to_date(V_IN_DATE,'DD/MM/YYYY')
                        AND lnt.txdate BETWEEN V_FROMDATE AND V_TODATE
                    GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
                ) lnt
                INNER JOIN
                (
                    SELECT lns.autoid, ln.acctno, ln.trfacctno, lns.rlsdate, lns.rate2 MRLOANRATE, --GianhVG sua ln.rate2 MRLOANRATE,
                        ln.prinperiod MRLOANPERIOD,
                        LN.rate2 GRLOANRATE, --Gianhvg sua LN.orate2 GRLOANRATE,
                        LN.oprinperiod GRLOANPERIOD,
                        lns.nml + lns.ovd MRprinamt, lns.nml + lns.ovd GRPRINAMT,
                        DECODE(LN.RRTYPE,'C','BMSC', NVL(LN.CUSTBANK,'BMSC')) CUSTBANK, NVL(CF.FULLNAME,'BMSC') BANKNAME ,NVL(CF.shortname,'BMSC') BANKSHORTNAME
                    FROM vw_lnmast_all LN, vw_lnschd_all lns, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                    WHERE ln.acctno = lns.acctno  -- AND lnS.rlsdate  = to_date(V_IN_DATE,'DD/MM/YYYY')
                    and lnS.rlsdate between V_CFROMDATE and V_CTODATE
                        AND LN.CUSTBANK = CF.CUSTID (+)
                    /*SELECT ln.acctno, ln.trfacctno, ln.rlsdate, ln.rate2 MRLOANRATE, ln.prinperiod MRLOANPERIOD,
                        LN.orate2 GRLOANRATE, LN.oprinperiod GRLOANPERIOD,
                        ln.prinnml + LN.prinovd MRprinamt, LN.oprinnml + LN.oprinovd GRPRINAMT,
                        NVL(LN.CUSTBANK,'BMSC') CUSTBANK, NVL(CF.FULLNAME,'BMSC') BANKNAME
                    FROM vw_lnmast_all LN, cfmast cf
                    WHERE LN.CUSTBANK = CF.CUSTID (+)*/
                ) ln
                ON lnt.lnacctno = LN.acctno AND lnt.lnsautoid = ln.autoid --AND ln.CUSTBANK LIKE V_CUSTBANK
                INNER JOIN
                (
                    SELECT CF.custodycd, AF.acctno, CF.fullname
                    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, AFTYPE AFT
                    WHERE CF.custid = AF.custid
                    AND AF.ACCTNO LIKE V_AFACCTNO
                    AND CF.CUSTODYCD LIKE V_CUSTODYCD
                    AND AFT.ACTYPE = AF.ACTYPE
                    AND AFT.PRODUCTTYPE LIKE V_AFTYPE
                ) CF
                ON LN.trfacctno = CF.ACCTNO
                LEFT JOIN
                (
                    SELECT lnt.acctno lnacctno, sum(lnt.namt) ORGPAIDAMT, lnt.acctref lnsautoid
                    FROM vw_lntran_all lnt
                    WHERE lnt.tltxcd IN ('5540','5567') AND lnt.TXCD IN ('0014','0065')
                        --AND lnt.txdate >= to_date(V_IN_DATE,'DD/MM/YYYY')
                        AND lnt.txdate BETWEEN V_FROMDATE AND V_TODATE
                    GROUP BY lnt.acctno, lnt.acctref
                ) PS
                ON lnt.lnacctno = PS.lnacctno AND lnt.lnsautoid = ps.lnsautoid
        ) A
        WHERE A.LOANTYPE LIKE V_SVTYPE
            AND A.BANKSHORTNAME LIKE V_CUSTBANK
           -- AND TO_DATE(A.RLSDATE,'DD/MM/YYYY')= to_date(V_IN_DATE,'DD/MM/YYYY')
            AND TO_DATE(A.RLSDATE,'DD/MM/YYYY')  between V_CFROMDATE and V_CTODATE
            AND (SUBSTR(A.AFACCTNO,1,4) LIKE V_STRBRID OR INSTR(V_STRBRID,SUBSTR(A.AFACCTNO,1,4)) >0)
        ORDER BY A.custodycd, A.AFACCTNO, A.RLSDATE, A.lnacctno;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
