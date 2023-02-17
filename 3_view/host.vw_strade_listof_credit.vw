SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_LISTOF_CREDIT
(BANKID, REFNUM, CUSTODYCD, ACCTNO, FULLNAME, 
 AMT, DESCRIPTION, BUSDATE, STATUS, ERRORDESC, 
 DELTD, BANKACCTNO, RETURNID, LAST_CHANGE)
BEQUEATH DEFINER
AS 
SELECT t.bankid,t.refnum,t.custodycd, t.acctno,c.fullname, t.amt, t.description, t.busdate, t.status, t.errordesc, t.deltd, b.bankacctno, t.autoid returnid,
t.last_change
FROM tblcashdeposit t, cfmast c, banknostro b
WHERE t.bankid = b.shortname and t.custodycd = c.custodycd and t.tltxcd = '1191'
/
