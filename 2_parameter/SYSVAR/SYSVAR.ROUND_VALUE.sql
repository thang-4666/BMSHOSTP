SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('ROUND_VALUE','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'ROUND_VALUE', '10', 'Gia tri lam tron tien, check khi dong HD, chuyen Corebank', '', 'N', 'A', 'P');COMMIT;