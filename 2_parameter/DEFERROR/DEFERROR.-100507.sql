SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100507;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100507, '[-100507]: ERR_SA_ACCTNO_DUPLICATED.', '[-100507]: ERR_SA_ACCTNO_DUPLICATED', 'SA', NULL);COMMIT;