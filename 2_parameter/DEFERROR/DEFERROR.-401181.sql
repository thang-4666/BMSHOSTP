SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -401181;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-401181, '[-401181]: Số tiền gửi phải lớn hơn hoặc bằng số tiền tối thiểu qui định !', '[-401181]:  Số tiền gửi phải lớn hơn hoặc bằng số tiền tối thiểu qui định!', 'CI', NULL);COMMIT;