SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -260168;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-260168, '[-260168]: Tài khoản nhận phải khác tài khoản chuyển!', '[-260168]: ERR_CF_AFMAST_STATUS_INVALID', 'CF', NULL);COMMIT;