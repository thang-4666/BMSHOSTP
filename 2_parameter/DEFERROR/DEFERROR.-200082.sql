SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200082;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200082, '[-200082]: Số tiểu khoản phải là số !', '[-200082]: ERR_AF_ACCTNO_ISNUMBERIC !', 'CF', NULL);COMMIT;