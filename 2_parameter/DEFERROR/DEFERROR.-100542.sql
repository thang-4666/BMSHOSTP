SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100542;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100542, '[-100542]: Không phải TK Margin !', '[-100542]: Not a Margin Sub Account !', 'PR', NULL);COMMIT;