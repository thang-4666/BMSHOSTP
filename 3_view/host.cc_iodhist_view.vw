SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CC_IODHIST_VIEW
(ORDERID, BORS, SYMBOL, ACCTNO, MATCHPRICE, 
 TXDATE, MATCHQTTY)
BEQUEATH DEFINER
AS 
SELECT a.orgorderid orderid, a.bors , a.symbol, om.AFACCTNO ,
       a.matchprice, a.txdate, sum(a.matchqtty) matchqtty
  FROM (select orgorderid  ,bors , symbol,
    matchprice, txdate,matchqtty,deltd
       from iod
       where deltd<>'Y'
       union all
       select orgorderid  ,bors , symbol,
       matchprice, txdate,matchqtty,deltd
       from iodhist
       where deltd<>'Y') a,
       (select * from odmast where deltd<>'Y'
        union all
        select * from odmasthist where deltd<>'Y') om
  where 
orgorderid=om.ORDERID
  and a.txdate=om.txdate
  group by a.orgorderid , a.bors , a.symbol, om.AFACCTNO ,
       a.matchprice, a.txdate
/
