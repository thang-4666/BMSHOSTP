SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('ONLINEMINREMAINTRF1101_AMT','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'ONLINEMINREMAINTRF1101_AMT', '0', 'So tien chuyen khoan ra ngan hang con lai toi thieu', 'So tien chuyen khoan ra ngan hang con lai toi thieu', 'N', 'A', 'P');COMMIT;