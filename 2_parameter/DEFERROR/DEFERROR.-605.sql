SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -605;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-605, 'Vượt quá hạn mức đầu tư', 'Vượt quá hạn mức đầu tư', 'PM', NULL);COMMIT;