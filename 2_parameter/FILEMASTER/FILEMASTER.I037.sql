SET DEFINE OFF;DELETE FROM FILEMASTER WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I037','NULL');Insert into FILEMASTER   (EORI, FILECODE, FILENAME, FILEPATH, TABLENAME, SHEETNAME, ROWTITLE, DELTD, EXTENTION, PAGE, PROCNAME, PROCFILLTER, OVRRQD, MODCODE, RPTID, CMDCODE, EXCELFILENAME) Values   ('T', 'I037', 'Import giao dịch chuyển chứng khoán ra ngoài (2244)', '', 'TBLSE2244', '1', 1, 'N', '.xls', 100, 'PR_FILE_TBLSE2244', '', 'N', 'SE', 'V_SE2244', 'SE', 'IMP_SE2244');COMMIT;