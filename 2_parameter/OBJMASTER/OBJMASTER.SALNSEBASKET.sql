SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.LNSEBASKET','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('SA', 'SA.LNSEBASKET', 'TT Rổ chứng khoán', 'Basket securities', 'Y', 'N', 'NNNNYYY');COMMIT;