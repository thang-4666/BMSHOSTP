SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100009;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100009, '[-100009]: Nhóm này có chứa người sử dụng', '[-100009]: This group contain some users!', 'SA', NULL);COMMIT;