SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.SECURITIES_NAV','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('SA', 'SA.SECURITIES_NAV', 'NAV', 'NAV', 'Y', 'N', 'NNNNYYY');COMMIT;