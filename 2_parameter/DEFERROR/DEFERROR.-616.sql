SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -616;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-616, 'Chưa đến thời hạn mua của chứng khoán/Phương án', 'Chưa đến thời hạn mua của chứng khoán/Phương án', 'PM', NULL);COMMIT;