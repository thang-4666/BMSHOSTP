SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700130;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700130, '[-700130]: Lệnh đã khớp và hủy map, không được phép map lại!', '[-700130]: Lệnh đã khớp và hủy map, không được phép map lại!', 'OD', NULL);COMMIT;