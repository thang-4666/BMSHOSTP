SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100902;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100902, '[-100902]: Mật khẩu xác nhận không đúng!', '[-100902]: Mật khẩu xác nhận không đúng!', 'DL', NULL);COMMIT;