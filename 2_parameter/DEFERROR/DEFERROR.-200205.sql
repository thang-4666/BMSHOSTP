SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200205;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200205, '[-200205]: Hết hạn giấy tờ (CMND) trên thông tin khách hàng!', '[-200205]: Hết hạn giấy tờ (CMND) trên thông tin khách hàng!', 'CF', NULL);COMMIT;