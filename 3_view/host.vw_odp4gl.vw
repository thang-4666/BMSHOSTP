SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ODP4GL
(TRADATE, SETTDATE, P_BAMT, P_SAMT, C_BAMT, 
 C_SAMT, F_BAMT, F_SAMT, TRADEPLACE, SYMBOL, 
 BRID, TXBRID, TXTIME)
BEQUEATH DEFINER
AS 
SELECT io.txdate TRADATE  ,sts.cleardate SETTDATE  , decode (io.bors,'B',IO.matchprice*IO.matchqtty,'S',0) P_BAMT, decode (io.bors,'S',IO.matchprice*IO.matchqtty,'B',0)
 P_SAMT, 0 C_BAMT,0 C_SAMT,0 F_BAMT,0 F_SAMT,to_char(sb.tradeplace) tradeplace ,sb.symbol,
af.brid brid , CASE when SUBSTR(sts.orgorderid,1,4) <>'0101' THEN '0001' ELSE SUBSTR(sts.orgorderid,1,4) END txbrid, io.txtime
  FROM vw_iod_all io,vw_stschd_all sts , sbsecurities sb,afmast af 
WHERE io.orgorderid = sts.orgorderid  
AND sts.codeid = sb.codeid 
AND sts.afacctno = af.acctno 
AND substr(io.custodycd,4,1)='P'
/
