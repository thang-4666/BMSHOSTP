SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('CICRINTPRN','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('0302', 'CI', 'CICRINTPRN', 'Lãi nhập gốc', 'EOD', ' ', 'N', 'CIIC', 'Lãi nhập gốc...', ' ', ' ', ' ', 5000, 'DB', 'Y');COMMIT;