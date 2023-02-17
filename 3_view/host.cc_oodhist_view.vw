SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CC_OODHIST_VIEW
(ACCTNO, ORDERID, SYMBOL, BORS, PRICE, 
 QTTY, TXDATE, TXTIME)
BEQUEATH DEFINER
AS 
SELECT  t.AFACCTNO acctno,a.orgorderid orderid,  a.symbol,  a.bors, a.price, a.qtty,
         a.txdate,
         a.txtime
		 FROM oodhist a, (select * from odmast union all select * from odmasthist) t
  where a.deltd <>'Y' and oodstatus ='S'
  and  a.bors in('B','S')
  and t.ORDERID=a.orgorderid
  and t.txdate=a.txdate
union all
SELECT  t.AFACCTNO acctno,a.orgorderid orderid,  a.symbol,  a.bors, a.price, a.qtty,
         a.txdate,
         a.txtime
		 FROM ood a, odmast  t
  where a.deltd <>'Y' and oodstatus ='S'
  and  a.bors in('B','S')
  and t.ORDERID=a.orgorderid
  and t.txdate=a.txdate
/
