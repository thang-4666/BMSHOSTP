SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('CIODRCV','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('0016', 'CI', 'CIODRCV', 'Hoàn trả thấu chi', 'EOD', 'BF', 'N', 'CIIC', 'Hoàn trả thấu chi...', ' ', ' ', ' ', 0, 'NET', 'N');COMMIT;