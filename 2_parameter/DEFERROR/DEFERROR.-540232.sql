SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -540232;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-540232, '[-540232]: Món vay không thuộc tiểu khoản thực hiện, kiểm tra lại thông tin món vay!', '[-540232]: Món vay không thuộc tiểu khoản thực hiện, kiểm tra lại thông tin món vay!', 'LN', NULL);COMMIT;