SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100087;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100087, '[-100087]: Mã ngân hàng này đã tồn tại!', '[-100050]: Bank code is duplicated!', 'SA', NULL);COMMIT;