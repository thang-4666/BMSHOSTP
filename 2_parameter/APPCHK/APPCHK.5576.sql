SET DEFINE OFF;DELETE FROM APPCHK WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('5576','NULL');Insert into APPCHK   (TLTXCD, APPTYPE, ACFLD, RULECD, AMTEXP, FLDKEY, DELTDCHK, ISRUN, CHKLEV) Values   ('5576', 'LN', '03', '11', '@PR', 'ACCTNO', 'N', '@1', 0);COMMIT;