SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('IMG_FOOTER','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'IMG_FOOTER', 'https://bmsc.com.vn/assets/images/bmsc_email.png', 'Footer EMAIL', 'Footer EMAIL', 'Y', 'A', 'AP');COMMIT;