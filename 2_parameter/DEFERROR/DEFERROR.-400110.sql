SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400110;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400110, '[-400110]: Vượt quá số tiền khả dụng của tiểu khoản!', '[-400110]:Vượt quá số tiền khả dụng của tiểu khoản!', 'CI', NULL);COMMIT;