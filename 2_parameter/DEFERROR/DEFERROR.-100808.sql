SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100808;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100808, '[-100808]: Tiểu khoản đã được gán vào nhóm tính phí theo số lưu ký !', '[-100808]: Account has been in custody broker fee group', 'SA', NULL);COMMIT;