SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -260159;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-260159, '[-260159]: Tài khoản vẫn còn chứng khoán phong tỏa !', '[-260159]:  Tài khoản vẫn còn chứng khoán phong tỏa', 'CF', NULL);COMMIT;