SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GL_STOCK_INFO_HIST
(SYMBOL, TXDATE, BASICPRICE)
BEQUEATH DEFINER
AS 
select  sbh.symbol , to_char(histdate,'YYYY-MM-DD' ) txdate  ,  
case when sb.sectype ='001' then 
     case when sb.halt ='Y' THEN 0 ELSE  sbh.avgprice END 
else 10000 end 
 basicprice 
from securities_info_hist sbh, sbsecurities sb
where sbh.codeid  = sb.codeid
and sb.tradeplace in ('001','002','005') and  sb.sectype <>'004'
/
