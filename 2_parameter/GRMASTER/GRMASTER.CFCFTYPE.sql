SET DEFINE OFF;DELETE FROM GRMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.CFTYPE','NULL');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('CF', 'CF.CFTYPE', 0, 'MAIN', 'N', 'NNNNNNNN', 'Thông tin chung', 'Common', 'N', '');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('CF', 'CF.CFTYPE', 1, 'CFAFTYPE', 'G', 'EEEENNNN', 'Danh sách loại hình tiểu khoản', 'atype list', 'N', 'CFAFTYPE');COMMIT;