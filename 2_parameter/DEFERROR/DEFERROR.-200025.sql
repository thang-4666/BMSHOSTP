SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -200025;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-200025, '[-200025]: ERR_CF_AFMAST_TRADERATE_OVER_AFTYPE!', '[-200025]: ERR_CF_AFMAST_TRADERATE_OVER_AFTYPE!', 'CF', NULL);COMMIT;