SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('STRICTCANCELSTARTTIME','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('OL', 'STRICTCANCELSTARTTIME', '0820', 'Thoi gian bat dau kiem soat huy lenh', 'Thoi gian bat dau kiem soat huy lenh', 'N', 'A', 'P');COMMIT;