SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -561027;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-561027, '[-561027] : Tổng tỷ lệ nhận hoa hồng của các trường nhóm không được lớn hơn 100', '[-561027] : Total group rate must be <= 100', 'RE', 0);COMMIT;