SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -260008;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-260008, '[-260008] Số lượng chứng khoán phong toả không đủ để làm deal', '[-260008] Số lượng chứng khoán phong toả không đủ để làm deal', 'DF', NULL);COMMIT;