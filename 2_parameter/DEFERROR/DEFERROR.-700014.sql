SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -700014;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-700014, '[-700014]: Bước giá không phù hợp', '[-700014]: TICKSIZE INCOMPLIANT!', 'OD', NULL);COMMIT;