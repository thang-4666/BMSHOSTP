SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100189;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100189, '[-100189]: Còn khách hàng sử dựng hạn mức bảo lãnh của ngân hàng!', '[-100189]: Còn khách hàng sử dựng hạn mức bảo lãnh của ngân hàng!', 'SA', NULL);COMMIT;