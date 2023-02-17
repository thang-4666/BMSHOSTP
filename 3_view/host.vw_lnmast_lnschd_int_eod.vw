SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNMAST_LNSCHD_INT_EOD
(LAIA, ACCTNO, LAIB)
BEQUEATH DEFINER
AS 
select a.intnmlacr+a.intdue+a.intnmlovd+a.intovdacr laia , a.acctno, b.laib from lnmast a,
(select sum(intnmlacr+intdue+intovd+intovdprin) laib, acctno from lnschd where reftype='P' group by acctno) b
where a.acctno=b.acctno and a.intnmlacr+a.intdue+a.intnmlovd+a.intovdacr-b.laib>1
/
