SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('REPORTVERSION','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'REPORTVERSION', 'reports.6.5.0.0017.0012', 'PhiÃªn báº£n má»›i nháº¥t cá»§a Report', '', 'N', 'A', 'P');COMMIT;