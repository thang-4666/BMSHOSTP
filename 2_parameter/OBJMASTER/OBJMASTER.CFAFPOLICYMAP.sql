SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.AFPOLICYMAP','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('CF', 'CF.AFPOLICYMAP', 'Danh sách tiểu khoản', 'Sub-account belong to policy', 'Y', 'N', 'NNNNYYY');COMMIT;