SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -540239;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-540239, '[-540239]:vượt quá số ngày được phép gia hạn của món vay, không được phép gia hạn!', '[-540239]:vượt quá số ngày được phép gia hạn của món vay, không được phép gia hạn!', 'LN', NULL);COMMIT;