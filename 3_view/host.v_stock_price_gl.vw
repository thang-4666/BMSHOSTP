SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_STOCK_PRICE_GL
(TXDATE, SYMBOL, BASICPRICE, CLOSEPRICE, AVGPRICE, 
 TRADEPLACE, SECTYPE)
BEQUEATH DEFINER
AS 
SELECT to_char( se.histdate,'dd/mm/yyyy')  txdate ,se.symbol,se.basicprice,se.closeprice,se.avgprice,tradeplace,sectype
FROM securities_info_hist se,sbsecurities sb  WHERE sb.codeid = se.codeid AND  sb.tradeplace IN ('001','002','005') AND sb.sectype <>'004'
UNION 
SELECT to_char( getcurrdate,'dd/mm/yyyy')  txdate ,se.symbol,se.basicprice,se.closeprice,se.avgprice,tradeplace,sectype
FROM securities_info se,sbsecurities sb  WHERE sb.codeid = se.codeid AND  sb.tradeplace IN ('001','002','005')  AND sb.sectype <>'004'
/
