SET DEFINE OFF;DELETE FROM FILEMASTER WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I016','NULL');Insert into FILEMASTER   (EORI, FILECODE, FILENAME, FILEPATH, TABLENAME, SHEETNAME, ROWTITLE, DELTD, EXTENTION, PAGE, PROCNAME, PROCFILLTER, OVRRQD, MODCODE, RPTID, CMDCODE, EXCELFILENAME) Values   ('I', 'I016', 'ADSCHD (Data Conversion)', '', 'advancv', '1', 1, 'Y', '.xls', 100, '', '', 'N', '', '', '', '');COMMIT;