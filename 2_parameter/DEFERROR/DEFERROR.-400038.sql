SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400038;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400038, '[-400038]: Corebank account ', '[-400038]: Corebank account ', 'CI', NULL);COMMIT;