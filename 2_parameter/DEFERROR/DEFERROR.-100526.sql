SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100526;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100526, '[-100526]: Vượt quá quy định của nguồn đặc biệt của chứng khoán!', '[-100526]: Vượt quá quy định của nguồn đặc biệt của chứng khoán!', 'SA', NULL);COMMIT;