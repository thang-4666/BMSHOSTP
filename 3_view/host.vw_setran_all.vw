SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SETRAN_ALL
(TXNUM, TXDATE, ACCTNO, TXCD, NAMT, 
 CAMT, REF, DELTD, AUTOID, ACCTREF, 
 TLTXCD, BKDATE)
BEQUEATH DEFINER
AS 
select "TXNUM","TXDATE","ACCTNO","TXCD","NAMT","CAMT","REF","DELTD","AUTOID","ACCTREF","TLTXCD","BKDATE" from setran where deltd <> 'Y'
        union all
        select "TXNUM","TXDATE","ACCTNO","TXCD","NAMT","CAMT","REF","DELTD","AUTOID","ACCTREF","TLTXCD","BKDATE" from setrana  where deltd <> 'Y'
/
