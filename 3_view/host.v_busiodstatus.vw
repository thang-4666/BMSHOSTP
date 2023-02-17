SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_BUSIODSTATUS
(ORDERID, SYMBOL, MATCHPRICE, MATCHQTTY, CUSTID, 
 TXNUM, TXDATE, TXTIME)
BEQUEATH DEFINER
AS 
(
select iod.orgorderid orderid, iod.symbol,iod.MATCHPRICE,iod.MATCHQTTY,af.custid ,iod.txnum,iod.txdate,iod.txtime
from iod,odmast od,afmast af where iod.orgorderid=od.orderid
and od.afacctno=af.acctno)
/
