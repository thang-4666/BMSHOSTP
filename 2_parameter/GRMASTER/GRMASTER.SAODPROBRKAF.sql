SET DEFINE OFF;DELETE FROM GRMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.ODPROBRKAF','NULL');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('SA', 'SA.ODPROBRKAF', 0, 'MAIN', 'N', 'NNNNNNNN', 'TT chung', 'Common', 'N', '');COMMIT;