SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECK_SE_EOD
(ACCTNO, AMT, NAMT)
BEQUEATH DEFINER
AS 
select se.acctno, se.TRADE AMT, TR.NAMT  from semast se,sbsecurities sb ,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
from vw_setran_gen where field ='TRADE'
group by acctno )tr
where se.acctno = tr.acctno (+)
and se.codeid = sb.codeid
and nvl(SE.trade,0) <> nvl(tr.namt,0)
and sb.sectype <>'004'
UNION  ALL
select se.acctno, se.EMKQTTY AMT , TR.NAMT  from semast se,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
from vw_setran_gen where field ='EMKQTTY'
group by acctno )tr
where se.acctno = tr.acctno (+)
and nvl(SE.EMKQTTY,0) <> nvl(tr.namt,0)
UNION  ALL

select se.acctno, se.blocked AMT, TR.NAMT  from semast se,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
FROM VW_SETRAN_GEN WHERE FIELD ='BLOCKED'
group by acctno )tr
where se.acctno = tr.acctno (+)
and nvl(SE.BLOCKED,0) <> nvl(tr.namt,0)

UNION ALL
select se.acctno, se.STANDING AMT, TR.NAMT  from semast se,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
FROM VW_SETRAN_GEN WHERE FIELD ='STANDING'
group by acctno )tr
where se.acctno = tr.acctno (+)
and nvl(SE.STANDING,0) <> nvl(tr.namt,0)

UNION ALL
select se.acctno, se.NETTING AMT, TR.NAMT  from semast se,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
FROM VW_SETRAN_GEN WHERE FIELD ='NETTING'
group by acctno )tr
where se.acctno = tr.acctno (+)
and nvl(SE.NETTING,0) <> nvl(tr.namt,0)

UNION ALL
select se.acctno, se.RECEIVING AMT, TR.NAMT  from semast se,
(
select sum( case when  txtype ='C' THEN namt else -namt end) Namt ,acctno
FROM VW_SETRAN_GEN WHERE FIELD ='RECEIVING'
group by acctno )tr
where se.acctno = tr.acctno (+)
and nvl(SE.RECEIVING,0) <> nvl(tr.namt,0)

UNION ALL
SELECT SE.ACCTNO, SE.EMKQTTY AMT , TR.NAMT  FROM SEMAST SE,
(
SELECT SUM( CASE WHEN  TXTYPE ='C' THEN NAMT ELSE -NAMT END) NAMT ,ACCTNO
FROM VW_SETRAN_GEN WHERE FIELD ='EMKQTTY'
GROUP BY ACCTNO )TR
WHERE SE.ACCTNO = TR.ACCTNO (+)
AND NVL(SE.EMKQTTY,0) <> NVL(TR.NAMT,0)
/
