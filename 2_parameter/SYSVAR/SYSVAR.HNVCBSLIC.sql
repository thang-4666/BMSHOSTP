SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('HNVCBSLIC','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('DEFINED', 'HNVCBSLIC', 'Giấy phép HĐKD số: 01/UBCK-GP do UBCKNN cấp ngày 26 tháng 11 năm 1999.', 'Giấy phép của BMS', '', 'N', 'A', 'P');COMMIT;