SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700112;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700112, '[-700112]: KL đặt không được lớn hơn khối lượng còn lại của lệnh tổng', '[-700112]:  KL đặt không được lớn hơn khối lượng còn lại của lệnh tổng', 'OD', NULL);COMMIT;