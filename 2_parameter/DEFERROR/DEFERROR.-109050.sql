SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -109050;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-109050, '[-109050]: Không cho phép import khi đã có 1 bản ghi đang chờ duyệt!', '[-109050]: Không cho phép import khi đã có 1 bản ghi đang chờ duyệt!', 'SA', NULL);COMMIT;