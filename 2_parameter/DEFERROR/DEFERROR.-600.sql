SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -600;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-600, 'Lỗi chưa xác định', 'Lỗi chưa xác định', 'PM', NULL);COMMIT;