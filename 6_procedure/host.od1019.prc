SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD1019" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   FMONTH         IN       VARCHAR2,
   TMONTH         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   I_BRID         IN       VARCHAR2
     )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRTRADEPLACE              VARCHAR2 (8);
   V_STRI_BRID             VARCHAR2 (8);
   V_FDATE DATE ;
      V_TDATE DATE ;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);

V_FDATE := TO_DATE ('01'||FMONTH ,'DD/MM/YYYY') ;
V_TDATE := LAST_DAY( TO_DATE ('01'||TMONTH ,'DD/MM/YYYY'));

   IF (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%%';
   END IF;

   IF (I_BRID <> 'ALL')
   THEN
      V_STRI_BRID := I_BRID;
   ELSE
      V_STRI_BRID := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR
select to_char(sts.txdate,'mm/yyyy') txdate ,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='00' and od.matchtype ='N' THEN STS.amt ELSE 0 END) HS_CP_HSX_N,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='01' and od.matchtype ='N' THEN STS.amt ELSE 0 END) CN_CP_HSX_N,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' and od.matchtype ='N' THEN STS.amt ELSE 0 END) CT_CP_HSX_N,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='00' and od.matchtype ='P' THEN STS.amt ELSE 0 END) HS_CP_HSX_P,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='01' and od.matchtype ='P' THEN STS.amt ELSE 0 END) CN_CP_HSX_P,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='001' and od.matchtype ='P' THEN STS.amt ELSE 0 END) CT_CP_HSX_P,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_TP_HSX,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_TP_HSX,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='001'  THEN STS.amt ELSE 0 END) CT_TP_HSX,
      sum( CASE WHEN SB.sectype ='008' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_CCQ_HSX,
      sum( CASE WHEN SB.sectype ='008' AND STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_CCQ_HSX,
      sum( CASE WHEN SB.sectype ='008' AND STS.TRADEPLACE ='001'  THEN STS.amt ELSE 0 END) CT_CCQ_HSX,
      sum( CASE WHEN  STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_TH_HSX,
      sum( CASE WHEN  STS.TRADEPLACE ='001' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_TH_HSX,
      sum( CASE WHEN  STS.TRADEPLACE ='001'  THEN STS.amt ELSE 0 END) CT_TH_HSX,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_CP_HNX,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_CP_HNX,
      sum( CASE WHEN SB.sectype ='001' AND STS.TRADEPLACE ='002'  THEN STS.amt ELSE 0 END) CT_CP_HNX,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_TP_HNX,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_TP_HNX,
      sum( CASE WHEN SB.sectype IN ('003','006') AND STS.TRADEPLACE ='002'  THEN STS.amt ELSE 0 END) CT_TP_HNX,
      sum( CASE WHEN  STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_TH_HNX,
      sum( CASE WHEN  STS.TRADEPLACE ='002' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_TH_HNX,
      sum( CASE WHEN  STS.TRADEPLACE ='002'  THEN STS.amt ELSE 0 END) CT_TH_HNX,
      sum( CASE WHEN  STS.TRADEPLACE IN ('002','001') AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_TH_HNX_HSX,
      sum( CASE WHEN  STS.TRADEPLACE IN ('002','001') AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_TH_HNX_HSX,
      sum( CASE WHEN  STS.TRADEPLACE IN ('002','001')  THEN STS.amt ELSE 0 END) CT_TH_HNX_HSX,
      sum( CASE WHEN  STS.TRADEPLACE ='005' AND  SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS_UPCOM,
      sum( CASE WHEN  STS.TRADEPLACE ='005' AND  SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN_UPCOM,
      sum( CASE WHEN  STS.TRADEPLACE ='005'  THEN STS.amt ELSE 0 END) CT_UPCOM,
      sum( CASE WHEN    SUBSTR(STS.afacctno,1,2)='00'  THEN STS.amt ELSE 0 END) HS,
      sum( CASE WHEN    SUBSTR(STS.afacctno,1,2)='01'  THEN STS.amt ELSE 0 END) CN,
      sum(  STS.amt ) CT
from vw_stschd_tradeplace_all sts, sbsecurities sb, vw_odmast_all od
where sTs.codeid = sb.codeid
AND STS.orgorderid = od.orderid
and sts.deltd ='N' AND DUETYPE IN ('RM','SM')
and SUBSTR(STS.afacctno,1,2) like V_STRI_BRID
and  sts.tradeplace like V_STRTRADEPLACE
AND  STS.TXDATE  BETWEEN V_FDATE AND V_TDATE
group by to_char(sts.txdate,'mm/yyyy')


;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
