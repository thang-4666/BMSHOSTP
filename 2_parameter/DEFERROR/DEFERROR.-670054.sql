SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -670054;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-670054, '[-670054]: Mật khẩu mới trùng mật khẩu cũ', '[-670054]: New pass same old pass', 'RM', 0);COMMIT;