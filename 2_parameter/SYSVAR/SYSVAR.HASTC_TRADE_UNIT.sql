SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('HASTC_TRADE_UNIT','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'HASTC_TRADE_UNIT', '1', 'TRADE UNIT CUA SAN HN', '', 'N', 'A', 'P');COMMIT;