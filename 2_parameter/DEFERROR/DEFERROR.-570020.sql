SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -570020;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-570020, '[-570020] Tài khoản tự doanh không được làm giao dịch này!', '[-570020] Tài khoản tự doanh không được làm giao dịch này!', 'TD', NULL);COMMIT;