SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700072;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700072, '[-700072]: Chứng khoán này chỉ được đặt trong phiên liên tục', '[-700072]: Chứng khoán này chỉ được đặt trong phiên liên tục', 'OD', NULL);COMMIT;