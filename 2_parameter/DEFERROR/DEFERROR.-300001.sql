SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -300001;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-300001, '[-300001]: ERR_CA_BDS_HAS_CHILD', '[-300001]: ERR_CA_BDS_HAS_CHILD', 'CA', NULL);COMMIT;