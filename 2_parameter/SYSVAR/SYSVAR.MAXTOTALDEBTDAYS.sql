SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('MAXTOTALDEBTDAYS','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('MARGIN', 'MAXTOTALDEBTDAYS', '3600', 'Số ngày cho vay tối đa ( đã bao gồm các lần gia hạn)', 'Max debt day total', 'Y', 'A', 'PAPAPAPAPAPAPAP');COMMIT;