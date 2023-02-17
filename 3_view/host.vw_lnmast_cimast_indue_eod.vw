SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LNMAST_CIMAST_INDUE_EOD
(ACCTNO, LNACCOUNT, DUEAMT, LNSDUE, AMT)
BEQUEATH DEFINER
AS 
select a.acctno,b.acctno lnaccount, a.dueamt, c.lnsdue,a.dueamt- c.lnsdue amt from cimast a, lnmast b,
 (select sum(nml+intdue) lnsdue,acctno from lnschd where overduedate=getcurrdate() and reftype='P' group by acctno)  c
 where a.acctno=b.trfacctno and b.acctno=c.acctno and a.dueamt<> c.lnsdue
/
