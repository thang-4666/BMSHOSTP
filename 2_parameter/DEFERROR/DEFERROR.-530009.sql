SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -530009;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-530009, 'Unmortaged amount is over mortaged amount', 'Unmortaged amount is over mortaged amount', 'CL', NULL);COMMIT;