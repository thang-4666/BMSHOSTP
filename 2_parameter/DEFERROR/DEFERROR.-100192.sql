SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100192;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100192, '[-100192]:Số dư giao dịch không đủ!', '[-100192]:Số dư giao dịch không đủ !', 'SA', NULL);COMMIT;