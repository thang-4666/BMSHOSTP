SET DEFINE OFF;DELETE FROM APPCHK WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2653','NULL');Insert into APPCHK   (TLTXCD, APPTYPE, ACFLD, RULECD, AMTEXP, FLDKEY, DELTDCHK, ISRUN, CHKLEV) Values   ('2653', 'CI', '03', '01', '@A', 'ACCTNO', 'N', '@1', 0);COMMIT;