SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -540219;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-540219, '[-540219]: Ngày gia hạn phải lớn hơn ngày quá hạn cũ!', '[-540219]: Ngày gia hạn phải lớn hơn ngày quá hạn cũ!', 'LN', NULL);COMMIT;