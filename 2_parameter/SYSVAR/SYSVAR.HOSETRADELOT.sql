SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('HOSETRADELOT','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('OD', 'HOSETRADELOT', '100', 'Lô đặt lệnh sàn HOSE', 'Lô đặt lệnh sàn HOSE', 'N', 'A', '');COMMIT;