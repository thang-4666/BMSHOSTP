SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('SYSTEMSTARTDATE','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'SYSTEMSTARTDATE', '01/02/2012', 'Ngày bắt đầu chạy thật của hệ thống', 'System begin start date', 'N', 'A', 'P');COMMIT;