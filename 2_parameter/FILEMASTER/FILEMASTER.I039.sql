SET DEFINE OFF;DELETE FROM FILEMASTER WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I039','NULL');Insert into FILEMASTER   (EORI, FILECODE, FILENAME, FILEPATH, TABLENAME, SHEETNAME, ROWTITLE, DELTD, EXTENTION, PAGE, PROCNAME, PROCFILLTER, OVRRQD, MODCODE, RPTID, CMDCODE, EXCELFILENAME) Values   ('T', 'I039', 'Import tiền chờ về của sự kiện quyền', '', 'TBLCAI039', '1', 1, 'N', '.xls', 100, 'PR_FILE_TBLCAI039', '', 'N', 'CA', '', 'CA', '');COMMIT;