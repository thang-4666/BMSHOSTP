SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100145;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100145, '[-100145]:Thông tin khách hàng phải có sự thay đổi trên giao dịch!', '[-100145]:Thông tin khách hàng phải có sự thay đổi trên giao dịch!', 'CF', NULL);COMMIT;