SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('UPDPRICEPLO','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'UPDPRICEPLO', 'N', 'Cho phép cập nhật giá với những lệnh PLO trước phiên', 'Cho phép cập nhật giá với những lệnh PLO trước phiên', 'N', 'A', '');COMMIT;