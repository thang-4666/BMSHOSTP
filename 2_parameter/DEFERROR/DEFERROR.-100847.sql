SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100847;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100847, '[-100847]: Trùng mã biểu phí', '[-100847]: Duplicate actype', 'SA', NULL);COMMIT;