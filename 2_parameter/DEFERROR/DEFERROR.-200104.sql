SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200104;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200104, '[-200104]: Trạng thái khách hàng không hợp lệ', '[-200104]: Trạng thái khách hàng không hợp lệ', 'CF', NULL);COMMIT;