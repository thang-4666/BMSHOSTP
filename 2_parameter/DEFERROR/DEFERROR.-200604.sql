SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200604;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200604, '[-200604]: Gán trùng TraderID và tiểu khoản!', '[-200604]: Gán trùng TraderID và tiểu khoản!', 'CF', NULL);COMMIT;