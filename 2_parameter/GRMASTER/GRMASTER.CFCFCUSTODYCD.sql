SET DEFINE OFF;DELETE FROM GRMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.CFCUSTODYCD','NULL');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('CF', 'CF.CFCUSTODYCD', 0, 'MAIN', 'N', 'NNNNNNNN', 'TT chung', 'Common', 'N', '');Insert into GRMASTER   (MODCODE, OBJNAME, ODRNUM, GRNAME, GRTYPE, GRBUTTONS, GRCAPTION, EN_GRCAPTION, CAREBYCHK, SEARCHCODE) Values   ('CF', 'CF.CFCUSTODYCD', 1, 'CFAFCUSTODYCD', 'G', 'EENENNNN', 'Danh sách tiểu khoản', 'Sub-account', 'N', 'CFAFCUSTODYCD');COMMIT;