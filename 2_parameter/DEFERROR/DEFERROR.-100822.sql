SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100822;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100822, '[-100822]: MAXNAV không là trường số !', '[-100822]: MAXNAV không là trường số', 'DL', NULL);COMMIT;