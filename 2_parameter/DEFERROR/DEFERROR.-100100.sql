SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100100;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100100, '[-100100]: ERR_SA_HOST_VOUCHER_DOESNOT_FOUND', '[-100100]: ERR_SA_HOST_VOUCHER_DOESNOT_FOUND', 'SA', NULL);COMMIT;