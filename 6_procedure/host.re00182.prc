SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE RE00182 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS

-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Ngoc.vu      10/11/2016 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_INBRID           VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);

   v_fromdate        date;
   v_todate          date;

BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


    v_fromdate       := to_date(F_DATE,'dd/mm/rrrr');
    v_todate         := to_date(T_DATE,'dd/mm/rrrr');



     OPEN PV_REFCURSOR
     FOR
        SELECT * FROM (
                  SELECT OD.TXDATE,
                  ROUND(SUM(DECODE(BR.BRID,'0001' ,OD.EXECAMT,0))/1000) HSC,
                  ROUND(SUM(DECODE(BR.BRID,'0101' ,OD.EXECAMT,0))/1000) HCM,
                  ROUND(SUM(DECODE(BR.BRID,'0201' ,OD.EXECAMT,0))/1000) TPDN,
                  ROUND(SUM(DECODE(BR.BRID,'01010106' ,OD.EXECAMT,0))/1000) CANTHO,
                  ROUND(SUM(DECODE(BR.BRID,'00010002' ,OD.EXECAMT,0))/1000) GIANGVO,
                  ROUND(SUM(DECODE(BR.BRID,'00010003' ,OD.EXECAMT,0))/1000) HAIPHONG,
                  ROUND(SUM(DECODE(BR.BRID,'01010105' ,OD.EXECAMT,0))/1000) VUNGTAU,
                  ROUND(SUM(DECODE(BR.BRID,'01010102' ,OD.EXECAMT,0))/1000) PHUMYH,
                  ROUND(SUM(DECODE(BR.BRID,'01010103' ,OD.EXECAMT,0))/1000) DONGNAI,
                  ROUND(SUM(DECODE(BR.BRID,'01010104' ,OD.EXECAMT,0))/1000) ANGIANG,
                  ROUND(SUM(DECODE(BR.BRID,'01010107' ,OD.EXECAMT,0))/1000) BINHDUONG,
                  ROUND(SUM(DECODE(SB.TRADEPLACE,'001' ,OD.FEEACR,0))/1000) HOSE,
                  ROUND(SUM(DECODE(SB.TRADEPLACE,'002' ,OD.FEEACR,0))/1000) HNX,
                  ROUND(SUM(DECODE(SB.TRADEPLACE,'005' ,OD.FEEACR,0))/1000) UPCOM,
                  ROUND(SUM(OD.FEEACR)/1000) FEEACR

                  FROM VW_ODMAST_ALL OD, SBSECURITIES SB,AFMAST AF, CFMAST CF,
                              (SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY
                               FROM BRGRP BR, TLGROUPS TL
                               WHERE TL.GRPTYPE='2' 
                                      AND TL.GRPID NOT IN (SELECT CA.GRPID
                                      FROM TRADEPLACE PA, TRADECAREBY CA
                                      WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                              UNION ALL
                              SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                              FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID
                              ) BR
                  WHERE OD.CODEID=SB.CODEID
                                AND OD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID 
                                AND  CF.CAREBY=BR.CAREBY  AND CF.BRID=SUBSTR(BR.BRID,1,4)
                                AND SB.tradeplace IN ('001','002','005') and sb.SECTYPE in ('001')
                                AND OD.TXDATE BETWEEN v_fromdate AND v_todate
                                AND OD.EXECAMT+OD.FEEACR>0
                 GROUP BY OD.TXDATE
          )
           ORDER BY  TXDATE DESC ;




EXCEPTION
   WHEN OTHERS
   THEN

    OPEN PV_REFCURSOR
  FOR
  SELECT 0 A FROM DUAL WHERE 0=1;
End;
 
 
 
 
/
