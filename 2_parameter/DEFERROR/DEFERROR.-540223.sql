SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -540223;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-540223, '[-540223]: Loại hình vay đã được sử dụng, không cho phép thay đổi thông tin nguồn vay!', '[-540223]: Loại hình vay đã được sử dụng, không cho phép thay đổi thông tin nguồn vay!', 'LN', NULL);COMMIT;