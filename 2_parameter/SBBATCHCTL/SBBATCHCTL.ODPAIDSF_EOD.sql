SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('ODPAIDSF_EOD','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('0008', 'OD', 'ODPAIDSF_EOD', 'Trả phí lệnh bán', 'EOD', 'BF', 'N', 'ODRV', 'Trả phí lệnh bán...', ' ', ' ', ' ', 1000, 'DB', 'Y');COMMIT;