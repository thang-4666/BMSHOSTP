SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100608;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100608, '[-100608]: Hop dong khong margin', '[-100608]: ERR_SA_ACCTNO_NOT_IN_MARGIN_TYPE', 'CF', NULL);COMMIT;