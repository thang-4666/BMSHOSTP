SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400212;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400212, '[-400212]: Giao dịch không thể xóa vì tiểu khoản không đủ phí lưu ký cộng dồn!', '[-400212]: Giao dịch không thể xóa vì tiểu khoản không đủ phí lưu ký cộng dồn', 'CI', NULL);COMMIT;