SET DEFINE OFF;DELETE FROM OBJMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('AF.AFSELIMIT','NULL');Insert into OBJMASTER   (MODCODE, OBJNAME, OBJTITLE, EN_OBJTITLE, USEAUTOID, CAREBYCHK, OBJBUTTONS) Values   ('AF', 'AF.AFSELIMIT', 'Quy định giá trị CK vay tối đa cho tiểu khoản', 'Quy định giá trị CK vay tối đa cho tiểu khoản', 'Y', 'N', 'YYYYYYY');COMMIT;