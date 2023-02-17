SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CC_SEMAST_VIEW
(AFACCTNO, SYMBOL, TRADE, MORTAGE, BLOCKED, 
 SECURED)
BEQUEATH DEFINER
AS 
select se.afacctno ,s.symbol,se.trade, se.mortage, se.blocked, se.secured
from semast se, securities_info s
where se.codeid=s.codeid
and (se.trade<>0
or se.mortage<>0
or se.blocked<>0)
/
