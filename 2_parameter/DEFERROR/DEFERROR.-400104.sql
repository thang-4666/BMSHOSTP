SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400104;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400104, '[-400104]: Vượt quá số tiền chỉ dùng để giao dịch!', '[-400104]:Vượt quá số tiền chỉ dùng để giao dịch!', 'CI', NULL);COMMIT;