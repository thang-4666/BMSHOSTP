SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD2002" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2

   )
IS
-- MODIFICATION HISTORY
-- B?O C?O GIAO D?CH CH?NG KHO?N THEO S? T?I KHO?N KI? B?NG K?HOA H?NG M? GI?I PH?T SINH TRONG TH?NG
-- PERSON   DATE  COMMENTS
-- QUOCTA  29-12-2011  CREATED
-- GianhVG 03/03/2012 _modify
-- Them phan chia theo nguon tien quan ly cua khach hang
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID            VARCHAR2 (4);

   V_FDATE             DATE;
   V_TDATE             DATE;

BEGIN
    V_FDATE              :=    TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
    V_TDATE              :=    TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

OPEN PV_REFCURSOR
FOR
    select OD.txdate, DECODE(MAX(BK.HN_HCM), '00', 'Hà nội', '01','Hồ chí minh',
         DECODE(SUBSTR(MAX(OD.afacctno), 1, 2), '00', 'Hà nội', '01','Hồ chí minh')) HN_HCM_Text,
         SUM(DECODE(BK.HN_HCM, '00', OD.feeacr, 0)) FEE_HN,
         SUM(DECODE(BK.HN_HCM, '01', OD.feeacr, 0)) FEE_HCM,
         SUM(DECODE(NVL(BK.HN_HCM, '0'), '0', DECODE(SUBSTR(OD.afacctno, 1, 2), '00', OD.feeacr), 0)) FEE_HN1,
         SUM(DECODE(NVL(BK.HN_HCM, '0'), '0', DECODE(SUBSTR(OD.afacctno, 1, 2), '01', OD.feeacr), 0)) FEE_HCM1
    from vw_odmast_all OD
    left join (SELECT afcust.acctno, recflnk.brid, SUBSTR(recflnk.brid, 1, 2) HN_HCM,
         lnk.FRDATE, lnk.TODATE
        FROM afmast afcust, reaflnk lnk,  remast remst, retype tpy, recflnk
        WHERE  afcust.acctno=lnk.afacctno
        AND afcust.ACTYPE NOT IN ('0000') AND
        lnk.reacctno=remst.acctno
        and lnk.status='A'
        and substr(lnk.reacctno,11,4)=tpy.actype
        and tpy.rerole in('RM','BM')
        AND remst.custid=recflnk.custid) BK ON BK.acctno = OD.afacctno AND OD.TXDATE BETWEEN BK.FRDATE AND BK.TODATE
    WHERE      OD.TXDATE        BETWEEN V_FDATE AND V_TDATE
    GROUP BY OD.txdate
    ORDER BY OD.txdate;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST.OD2002

 
 
 
 
/
