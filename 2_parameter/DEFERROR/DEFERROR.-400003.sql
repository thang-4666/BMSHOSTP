SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400003;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400003, '[-400003]: Tiểu khoản tiền không tồn tại!', '[-400003]: ERR_CI_CIMAST_NOTFOUND', 'CI', NULL);COMMIT;