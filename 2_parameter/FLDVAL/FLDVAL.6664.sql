SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('6664','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('10', '6664', 0, 'V', '>>', '@0', '', 'Số tiền chuyển phải lớn hơn 0', 'Transfer amount must be greater than 0!', '', '', 0);COMMIT;