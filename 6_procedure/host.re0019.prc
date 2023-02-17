SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE RE0019 (
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

         SELECT BRNAME,BRID,TRADE,ROUND(EXECAMT/1000,4) EXECAMT,ROUND(EXECAMT_N/1000,4) EXECAMT_N,
              ROUND(GTGDHO/1000,4) GTGDHO,ROUND(GTGDHA/1000,4) GTGDHA,
              ROUND(GTGDUPCOM/1000,4) GTGDUPCOM,ROUND(GTGDHO_N/1000,4) GTGDHO_N,
              ROUND(GTGDHA_N/1000,4) GTGDHA_N,ROUND(GTGDUPCOM_N/1000,4) GTGDUPCOM_N,
              ROUND(FEEACR/1000,4) FEEACR,ROUND(FEEHO/1000,4) FEEHO,
              ROUND(FEEHA/1000,4) FEEHA,ROUND(FEEUPCOM/1000,4) FEEUPCOM
        FROM(
            SELECT BR.BRNAME, BR.BRID,'BMSC' TRADE, SUM(OD.EXECAMT) EXECAMT,
                    SUM(DECODE(OD.MATCHTYPE,'N',OD.EXECAMT,0)) EXECAMT_N,
                    SUM(DECODE(SB.TRADEPLACE,'001',OD.EXECAMT,0)) GTGDHO,
                    SUM(DECODE(SB.TRADEPLACE,'002',OD.EXECAMT,0)) GTGDHA,
                    SUM(DECODE(SB.TRADEPLACE,'005',OD.EXECAMT,0)) GTGDUPCOM,
                    SUM(DECODE(SB.TRADEPLACE,'001',DECODE(OD.MATCHTYPE,'N',OD.EXECAMT,0),0)) GTGDHO_N,
                    SUM(DECODE(SB.TRADEPLACE,'002',DECODE(OD.MATCHTYPE,'N',OD.EXECAMT,0),0)) GTGDHA_N,
                    SUM(DECODE(SB.TRADEPLACE,'005',DECODE(OD.MATCHTYPE,'N',OD.EXECAMT,0),0)) GTGDUPCOM_N,

                    SUM(OD.FEEACR) FEEACR,SUM(DECODE(SB.TRADEPLACE,'001',OD.FEEACR,0)) FEEHO,
                    SUM(DECODE(SB.TRADEPLACE,'002',OD.FEEACR,0)) FEEHA,
                    SUM(DECODE(SB.TRADEPLACE,'005',OD.FEEACR,0)) FEEUPCOM

            FROM VW_ODMAST_ALL OD, SBSECURITIES SB,AFMAST AF, CFMAST CF,
                                      (SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY
                                       FROM BRGRP BR, TLGROUPS TL
                                       WHERE TL.GRPTYPE='2' AND BR.ISACTIVE='Y'
                                              AND TL.GRPID NOT IN (SELECT CA.GRPID
                                              FROM TRADEPLACE PA, TRADECAREBY CA
                                              WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                                      UNION ALL
                                      SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                                      FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID
                                      ) BR
            WHERE OD.CODEID=SB.CODEID
                                        AND OD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
                                        AND  CF.CAREBY=BR.CAREBY AND CF.BRID=SUBSTR(BR.BRID,1,4)
                                        AND SB.tradeplace IN ('001','002','005') and sb.SECTYPE in ('001')
                                        AND OD.TXDATE BETWEEN v_fromdate AND v_todate
            GROUP BY  BR.BRID,BR.BRNAME

            UNION ALL

            SELECT 'VSD' BRNAME, 'VSD' BRID,'VSD' TRADE, SUM(TOTALVOLUME) EXECAMT,
                    SUM(TOTALVOLUME)-SUM(PT_TOTAL_VALUE) EXECAMT_N,
                    SUM(DECODE(MARKETID,'10',NVL(TOTALVOLUME,0),0)) GTGDHO,
                    SUM(DECODE(MARKETID,'02',NVL(TOTALVOLUME,0),0)) GTGDHA,
                    SUM(DECODE(MARKETID,'04',NVL(TOTALVOLUME,0),0)) GTGDUPCOM,
                    SUM(DECODE(MARKETID,'10',NVL(TOTALVOLUME,0)-NVL(PT_TOTAL_VALUE,0),0)) GTGDHO_N,
                    SUM(DECODE(MARKETID,'02',NVL(TOTALVOLUME,0)-NVL(PT_TOTAL_VALUE,0),0)) GTGDHA_N,
                    SUM(DECODE(MARKETID,'04',NVL(TOTALVOLUME,0)-NVL(PT_TOTAL_VALUE,0),0)) GTGDUPCOM_N,

                    0 FEEACR,0 FEEHO,0 FEEHA,0 FEEUPCOM

            FROM
                  (

                 SELECT SUM(NVL(TO_NUMBER(HI.TOTALVOLUME),0)) TOTALVOLUME,HI.MARKETID,
                        SUM(NVL(TO_NUMBER(HI.PT_TOTAL_VALUE),0)) PT_TOTAL_VALUE
                 FROM(
                  SELECT  HI.totalvalue TOTALVOLUME,HI.MARKETID, HI.PT_TOTAL_VALUE
                  FROM MARKETINFOR_HIST HI
                  WHERE HI.MARKETID IN ('10','02','04')
                        and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                        AND HI.TRADINGDATE IS NOT NULL

                  UNION ALL

                  SELECT  HI.totalvalue TOTALVOLUME,HI.MARKETID, HI.PT_TOTAL_VALUE
                  FROM MARKETINFOR HI
                  WHERE HI.MARKETID IN ('10','02','04')
                        and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                        AND HI.TRADINGDATE IS NOT NULL
                  ) HI GROUP BY HI.MARKETID
                  )
           )
              ORDER BY BRID;


EXCEPTION
   WHEN OTHERS
   THEN

    OPEN PV_REFCURSOR
  FOR
  SELECT 0 A FROM DUAL WHERE 0=1;
End;
 
 
 
 
/
