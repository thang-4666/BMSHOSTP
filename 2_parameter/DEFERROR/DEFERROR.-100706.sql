SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100706;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100706, '[-100706]:ERR_SA_CHANGEPASS_OLDPASSINVALID', '[-100706]:ERR_SA_CHANGEPASS_OLDPASSINVALID', 'SA', 0);COMMIT;