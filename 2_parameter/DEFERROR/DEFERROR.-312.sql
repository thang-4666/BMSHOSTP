SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -312;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-312, 'Trader không được phép giao dịch trên phương án', 'Trader không được phép giao dịch trên phương án', 'PM', NULL);COMMIT;