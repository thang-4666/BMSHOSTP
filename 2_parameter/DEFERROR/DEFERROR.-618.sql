SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -618;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-618, 'Vượt tỷ lệ lãi/lỗ của chứng khoán', 'Vượt tỷ lệ lãi/lỗ của chứng khoán', 'PM', NULL);COMMIT;