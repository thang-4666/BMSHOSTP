SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('ODFEECAL','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('0005', 'OD', 'ODFEECAL', 'Tính phí lệnh theo chính sách phí công ty', 'EOD', 'BF', 'N', 'ODCL', 'Tính phí lệnh theo chính sách phí công ty...', ' ', ' ', ' ', 0, 'DB', 'Y');COMMIT;