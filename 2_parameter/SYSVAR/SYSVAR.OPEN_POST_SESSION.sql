SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('OPEN_POST_SESSION','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'OPEN_POST_SESSION', 'N', 'Bắt đầu phiên giao dịch sau giờ', '', 'N', 'A', '');COMMIT;