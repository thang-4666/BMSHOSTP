SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SYMBOL_PRICE
(SYMBOL, BASICPRICE, TXDATE)
BEQUEATH DEFINER
AS 
(/*SELECT seif.SYMBOL, CASE WHEN sb.tradeplace IN ('001','002','005') THEN  basicprice ELSE  0 END  basicprice,get_t_date( histdate,1) TXDATE
FROM securities_info_hist SEIF,sbsecurities sb
WHERE seif.codeid = sb.codeid
UNION ALL
SELECT seif.SYMBOL, CASE WHEN sb.tradeplace IN ('001','002','005') THEN  basicprice ELSE  0 END  basicprice, get_t_date( getcurrdate,1) TXDATE
FROM securities_info SEIF,sbsecurities sb
WHERE seif.codeid = sb.codeid*/
select  sbh.symbol ,
case when sb.sectype ='001' then
     case when sb.halt ='Y' THEN 0 ELSE  sbh.avgprice END
else 10000 end
 basicprice , histdate txdate
from securities_info_hist sbh, sbsecurities sb
where sbh.codeid  = sb.codeid
and sb.tradeplace in ('001','002','005') and  sb.sectype <>'004'
)
/
