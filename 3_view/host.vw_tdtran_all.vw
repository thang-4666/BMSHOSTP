SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_TDTRAN_ALL
(AUTOID, TXDATE, TXNUM, ACCTNO, TXCD, 
 NAMT, CAMT, REF, ACCTREF, DELTD, 
 TLTXCD, BKDATE, TRDESC)
BEQUEATH DEFINER
AS 
SELECT a.autoid, a.txdate, a.txnum, a.acctno, a.txcd, a.namt, a.camt,
       a.ref, a.acctref, a.deltd, a.tltxcd, a.bkdate, a.trdesc
  FROM tdtran a where deltd <> 'Y'
union all
SELECT a.autoid, a.txdate, a.txnum, a.acctno, a.txcd, a.namt, a.camt,
       a.ref, a.acctref, a.deltd, a.tltxcd, a.bkdate, a.trdesc
  FROM tdtrana a where deltd <> 'Y'
/
