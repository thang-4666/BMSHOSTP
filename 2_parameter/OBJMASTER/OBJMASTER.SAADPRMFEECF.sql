SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.ADPRMFEECF','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('SA', 'SA.ADPRMFEECF', 'Danh sách tiểu khoản', 'Fee schema', 'Y', 'N', 'NNNNYYY');COMMIT;