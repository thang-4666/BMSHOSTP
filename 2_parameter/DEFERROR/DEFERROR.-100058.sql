SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100058;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100058, '[-100058]: ERR_SA_SYMBOL_NOTFOUND!', '[-100058]: ERR_SA_SYMBOL_NOTFOUND!', 'SA', NULL);COMMIT;