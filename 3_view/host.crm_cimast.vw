SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_CIMAST
(ACCTNO, BALANCE, COREBANK)
BEQUEATH DEFINER
AS 
SELECT c.acctno,c.balance, A.COREBANK
From cimast c, AFMAST A
WHERE C.acctno=A.acctno
/
