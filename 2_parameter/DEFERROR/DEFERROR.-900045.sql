SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -900045;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-900045, '[-900045]: Trạng thái của giao dịch thực rút chứng khoán không hợp lệ !', '[-900045]: INVALID STATUS 2201', 'SE', NULL);COMMIT;