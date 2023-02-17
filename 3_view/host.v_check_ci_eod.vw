SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECK_CI_EOD
(ACCTNO, AMT, NAMT)
BEQUEATH DEFINER
AS 
select  ci.acctno, ci.balance AMT, TR.NAMT   from cimast ci,afmast af,cfmast cf,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
from vw_citran_gen where field ='BALANCE'
group by acctno )tr
where ci.acctno = tr.acctno (+)
and nvl(ci.balance,0) <> nvl(tr.namt,0)
and ci.acctno = af.acctno
and af.custid = cf.custid
AND INSTR(cf.custodycd,'P')=0
UNION ALL
select ci.acctno, ci.EMKAMT AMT, TR.NAMT  from cimast ci,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
from vw_citran_gen where field ='EMKAMT'
group by acctno )tr
where ci.acctno = tr.acctno (+)
and nvl(ci.EMKAMT,0) <> nvl(tr.namt,0)
/
