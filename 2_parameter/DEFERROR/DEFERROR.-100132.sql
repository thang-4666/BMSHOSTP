SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100132;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100132, '[-100132]: Vượt quá số lần được phép chuyển khoản trong một ngày qua kênh giao dịch trực tuyến !', '[-100132]: Vượt quá số lần được phép chuyển khoản trong một ngày qua kênh giao dịch trực tuyến!', 'SA', NULL);COMMIT;