SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -570003;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-570003, 'Số tiền nhỏ hơn mức số dư tối thiểu', 'The amount less than minimum balance', 'TD', NULL);COMMIT;