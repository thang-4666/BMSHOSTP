SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -540235;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-540235, '[-540235]: Vượt quá hạn mức vay tuân thủ nguồn UBCK!', '[-540235]: Vượt quá hạn mức vay tuân thủ nguồn UBCK!', 'LN', NULL);COMMIT;