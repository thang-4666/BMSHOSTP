SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -670024;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-670024, '[-670024] : Người ký chưa được đăng ký', '[-670024] : Signer was not register', 'RM', 0);COMMIT;