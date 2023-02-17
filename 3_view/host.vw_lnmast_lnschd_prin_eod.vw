SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNMAST_LNSCHD_PRIN_EOD
(GOCA, ACCTNO, GOCB, TRFACCTNO)
BEQUEATH DEFINER
AS 
select a.prinnml+a.prinovd goca , a.acctno, b.gocb, a.trfacctno from lnmast a,
(select sum(nml+ovd) gocb, acctno from lnschd  where reftype='P' group by acctno) b
where a.acctno=b.acctno and a.prinnml+a.prinovd-b.gocb<>0
/
