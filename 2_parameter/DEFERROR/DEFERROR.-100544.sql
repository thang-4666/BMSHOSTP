SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100544;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100544, '[-100544]: Số lượng CK chuyển vượt quá SL chuyển tối đa !', '[-100544]: Số lượng CK chuyển vượt quá SL đã đánh dấu !', 'PR', NULL);COMMIT;