SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GL_P_ODMAST
(ACCTNO, TXDATE, EXECAMT, SYMBOL, EXECTYPE, 
 CLEARDATE)
BEQUEATH DEFINER
AS 
SELECT af.acctno,STS.txdate,amt execamt,sb.symbol,decode (sts.duetype,'RS','NB','NS') exectype,sts.cleardate
FROM vw_stschd_all sts,afmast af,cfmast cf,sbsecurities sb
WHERE duetype IN ('RS','RM')
AND sts.afacctno =af.acctno AND af.custid = cf.custid 
AND sb.codeid=sts.codeid 
AND cf.custodycd ='002P000001'
AND amt >0
AND sts.deltd <>'Y'
/
