SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0071" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DOANH THU
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   08-02-2012   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (40);
   V_BRID              VARCHAR2  (4);

   V_FDATE             DATE;
   V_TDATE             DATE;
   V_CRRDATE           DATE;

BEGIN
   V_STROPTION := upper(OPT);
   V_BRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSIF (V_STROPTION = 'B') then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_BRID;
   ELSE
        V_STRBRID := V_BRID;
   END IF;

-- GET REPORT'S PARAMETERS

   V_FDATE              :=    TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   V_TDATE              :=    TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

   SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CRRDATE
   FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

-- GET REPORT'S DATA
OPEN PV_REFCURSOR
FOR

     SELECT (CASE WHEN BR.BRID = '0001' THEN ' Hội sở '
             WHEN BR.BRID = '1000' THEN ' Chi nhánh HN '
             WHEN BR.BRID = '2000' THEN ' Chi nhánh HCM '
        ELSE TO_CHAR(BR.BRNAME) END) GR_I,
       (CASE WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'IC' THEN ' Cá nhan trong nước '
             WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'BC' THEN ' Tổ chức trong nước '
             WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'IF' THEN ' Cá nhân nước ngoài '
             WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'BF' THEN ' Tổ chức nước ngoài '
             WHEN (TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'P'                       THEN ' Tự doanh '
        END) GR_CUSTTYPE,
       (CASE WHEN SB.TRADEPLACE = '002' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END) HNX_FEE,
       (CASE WHEN SB.TRADEPLACE = '002' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END) HNX_AMT,
       (CASE WHEN SB.TRADEPLACE = '005' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END) UPCOM_FEE,
       (CASE WHEN SB.TRADEPLACE = '005' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END) UPCOM_AMT,
       (CASE WHEN SB.TRADEPLACE = '001' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END) HOSE_FEE,
       (CASE WHEN SB.TRADEPLACE = '001' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END) HOSE_AMT,
       ((CASE WHEN SB.TRADEPLACE = '002' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END) +
        (CASE WHEN SB.TRADEPLACE = '005' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END) +
        (CASE WHEN SB.TRADEPLACE = '001' THEN
             CASE WHEN OD.TXDATE = V_CRRDATE THEN ROUND(IO.MATCHQTTY * IO.MATCHPRICE * ODT.DEFFEERATE / 100, 2)
                  ELSE ROUND(OD.FEEACR, 2) END
             ELSE 0 END)) TOTAL_FEE,
        ((CASE WHEN SB.TRADEPLACE = '002' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END) +
         (CASE WHEN SB.TRADEPLACE = '005' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END) +
         (CASE WHEN SB.TRADEPLACE = '001' THEN
             (IO.MATCHQTTY * IO.MATCHPRICE)
             ELSE 0 END)) TOTAL_AMT

FROM   VW_ODMAST_ALL OD, VW_IOD_ALL IO, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, SBSECURITIES SB, BRGRP BR, ODTYPE ODT
WHERE  OD.DELTD                      <>    'Y'
AND    OD.ORDERID                    =     IO.ORGORDERID
--AND    OD.TXDATE                     =     IO.TXDATE
AND    OD.TXDATE                     BETWEEN V_FDATE AND V_TDATE
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND    IO.DELTD                      <>    'Y'
AND    OD.CODEID                     =     SB.CODEID
AND    OD.AFACCTNO                   =     AF.ACCTNO
AND    AF.CUSTID                     =     CF.CUSTID
AND    AF.ACTYPE                     NOT IN ('0000')
AND    TRIM(SUBSTR(CF.CUSTID, 1, 4)) =     BR.BRID
AND    OD.ACTYPE                     =     ODT.ACTYPE


;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST.OD0071

 
 
 
 
/
