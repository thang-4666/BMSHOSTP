SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.CRBTRFLOG','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('SA', 'SA.CRBTRFLOG', 'Quản lý bảng kê', 'List of voucher management', 'N', 'N', 'NNNNNYY');COMMIT;