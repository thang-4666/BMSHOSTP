SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700118;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700118, '[-700118]: Chứng khoán kiểm soát không được đặt loại giá MTL, MOK, MAK!', '[-700118]: Chứng khoán kiểm soát không được đặt loại giá MTL, MOK, MAK!', 'OD', 0);COMMIT;