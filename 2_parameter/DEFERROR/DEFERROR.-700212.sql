SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700212;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700212, '[-700212]: Yêu cầu giải tỏa lệnh không hợp lệ!', '[-700212]: Yeu cau giai toa lenh khong hop le!', 'OD', NULL);COMMIT;