SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -400204;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-400204, '[-400204]: Trạng thái bảng kê không đúng!', '[-400204]:AD Status invalid!', 'CI', NULL);COMMIT;