SET DEFINE OFF;DELETE FROM GRMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.ALLCODE','NULL');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('SA', 'SA.ALLCODE', 3, 'MAIN', 'N', 'EEEENNNN', 'Quản lý phòng/ban', 'Allcode', 'N', 'ALLCODE');COMMIT;