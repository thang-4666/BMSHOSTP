SET DEFINE OFF;DELETE FROM GRMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.BONDCUST','NULL');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('CF', 'CF.BONDCUST', 0, 'MAIN', 'N', 'NNNNNNNN', 'TT chung', 'Common', 'N', '');COMMIT;