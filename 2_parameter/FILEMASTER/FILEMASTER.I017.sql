SET DEFINE OFF;DELETE FROM FILEMASTER WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('I017','NULL');Insert into FILEMASTER   (EORI, FILECODE, FILENAME, FILEPATH, TABLENAME, SHEETNAME, ROWTITLE, DELTD, EXTENTION, PAGE, PROCNAME, PROCFILLTER, OVRRQD, MODCODE, RPTID, CMDCODE, EXCELFILENAME) Values   ('I', 'I017', 'Nộp tiền đồng bộ từ ngân hàng (1195)', '', 'TBLCASHDEPOSIT', '1', 1, 'N', '.xls', 100, 'pr_CashDepositUpload', 'pr_CashDepositUpload', 'N', '', 'CI1195', '', '');COMMIT;