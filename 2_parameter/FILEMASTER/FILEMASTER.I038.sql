SET DEFINE OFF;DELETE FROM FILEMASTER WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I038','NULL');Insert into FILEMASTER   (EORI, FILECODE, FILENAME, FILEPATH, TABLENAME, SHEETNAME, ROWTITLE, DELTD, EXTENTION, PAGE, PROCNAME, PROCFILLTER, OVRRQD, MODCODE, RPTID, CMDCODE, EXCELFILENAME) Values   ('T', 'I038', 'Import phong tỏa chứng khoán (2202)', '', 'TBLSE2202', '1', 1, 'N', '.xls', 100, 'PR_FILE_TBLSE2202', '', 'N', 'SE', 'V_SE2202', 'SE', 'IMP_SE2202');COMMIT;