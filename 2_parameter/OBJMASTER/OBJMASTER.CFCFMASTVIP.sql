SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.CFMASTVIP','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('CF', 'CF.CFMASTVIP', 'Quản lý khách hàng VIP', 'VIP Customer Management', 'N', 'N', 'NNNNYYY');COMMIT;