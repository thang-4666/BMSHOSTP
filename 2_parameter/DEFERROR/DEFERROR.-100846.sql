SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100846;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100846, '[-100846]: Tham số nguồn hệ thống, không được phép chỉnh sửa, xóa!', '[-100846]: Tham số nguồn hệ thống, không được phép chỉnh sửa, xóa!', 'SA', NULL);COMMIT;