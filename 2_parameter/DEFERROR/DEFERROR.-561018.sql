SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -561018;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-561018, '[-561018] : Loại hình môi giới tương lai không đúng', '[-561018] : Imvalid future retype', 'RE', 0);COMMIT;