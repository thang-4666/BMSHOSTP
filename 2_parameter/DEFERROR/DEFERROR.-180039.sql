SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -180039;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-180039, '[-180039]: Không được cấp bảo lãnh cho tài khoản Margin', '[-180039]:Can not do this for Margin account!', 'MR', NULL);COMMIT;