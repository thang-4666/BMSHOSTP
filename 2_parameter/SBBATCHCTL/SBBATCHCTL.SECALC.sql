SET DEFINE OFF;DELETE FROM SBBATCHCTL WHERE 1 = 1 AND NVL(BCHMDL,'NULL') = NVL('SECALC','NULL');Insert into SBBATCHCTL   (BCHSQN, APPTYPE, BCHMDL, BCHTITLE, RUNAT, ACTION, RPTPRINT, TLBCHNAME, MSG, BKP, BKPSQL, RSTSQL, ROWPERPAGE, RUNMOD, STATUS) Values   ('3001', 'SE', 'SECALC', 'Tính lại giá vốn chứng khoán  ', 'BOD', '', 'N', 'SECL', 'Tính lại giá vốn chứng khoán ...', ' ', ' ', ' ', 0, 'DB', 'Y');COMMIT;