SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_SEMAST
(ACCTNO, CODEID, SYMBOL, TRADE, MORTAGE, 
 BLOCKED, SECURED, COSTPRICE)
BEQUEATH DEFINER
AS 
select se.afacctno ,se.codeid,s.symbol,se.trade, se.mortage, se.blocked, se.secured,se.costprice
from semast se, securities_info s
where se.codeid=s.codeid
and (se.trade<>0
or se.mortage<>0
or se.blocked<>0)
/
