SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.GLRULES','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('SA', 'SA.GLRULES', 'Qui định hạch toán kế toán', 'GL Posting entry definition', 'Y', 'N', 'NNNNYYY');COMMIT;