SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -201420;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-201420, '[-201420]: Lệnh của tiểu khoản thường đã được chuyển thành lệnh của tiểu khoản magin !', '[-201420]: Lệnh của tiểu khoản thường đã được chuyển thành lệnh của tiểu khoản magin!', 'SA', NULL);COMMIT;