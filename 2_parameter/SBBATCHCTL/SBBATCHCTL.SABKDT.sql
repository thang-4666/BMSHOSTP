SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('SABKDT','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('2998', 'SA', 'SABKDT', 'Lưu trữ dữ liệu', 'EOD', ' ', 'N', 'SAGW', 'Lưu trữ dữ liệu...', ' ', ' ', ' ', 0, 'DB', 'Y');COMMIT;