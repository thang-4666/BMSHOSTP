SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200094;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200094, '[-200094]: Loại hình credit line chưa được duyệt.', '[-200094]: MRTYPE not approved', 'SA', NULL);COMMIT;