SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100708;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100708, 'Ngày backdate không hợp lệ', 'Backdate is invalid', 'SA', NULL);COMMIT;