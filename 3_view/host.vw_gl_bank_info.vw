SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_BANK_INFO
(BANKID, SHORT_BANK_NAME, FULL_BANK_NAME, BANKACCTNO)
BEQUEATH DEFINER
AS 
SELECT SHORTNAME BANKID, FULLNAME SHORT_BANK_NAME, FULLNAME FULL_BANK_NAME, BANKACCTNO
FROM BANKNOSTRO
/
