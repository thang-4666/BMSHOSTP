SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -300044;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-300044, '[-300044]:Số lượng chứng khoán quyền bán vượt quá số lượng CK quyền còn lại !', '[-300044]:Số lượng chứng khoán quyền bán vượt quá số lượng CK quyền còn lại!', 'CA', NULL);COMMIT;