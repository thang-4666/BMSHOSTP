SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -300005;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-300005, '[-300005]: CA ALREADY APPROVED, SENT OR COMPLETE', '[-300005]: CA ALREADY APPROVED, SENT OR COMPLETE', 'CA', NULL);COMMIT;