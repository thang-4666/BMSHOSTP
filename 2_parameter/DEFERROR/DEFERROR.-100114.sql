SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100114;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100114, '[-100114]:ERR_SA_EXTREFDEF_CONTRAINT!', '[-100114]:ERR_SA_EXTREFDEF_CONTRAINT!', 'SA', NULL);COMMIT;