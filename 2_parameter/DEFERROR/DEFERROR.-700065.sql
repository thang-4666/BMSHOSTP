SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700065;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700065, '[-700065]: Lệnh bán chứng khoán vượt quá hạn mức về tỉ lệ hoặc giá trị giao dịch!', '[-700065]: Lệnh bán chứng khoán vượt quá hạn mức về tỉ lệ hoặc giá trị giao dịch!', 'OD', NULL);COMMIT;