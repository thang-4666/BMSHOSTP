SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -670065;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-670065, '[-670065]: Số dư phong toả không có', '[-670065]: Hold balance zero', 'RM', 0);COMMIT;