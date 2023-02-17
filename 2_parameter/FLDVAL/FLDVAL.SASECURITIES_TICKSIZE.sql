SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.SECURITIES_TICKSIZE','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('FROMPRICE', 'SA.SECURITIES_TICKSIZE', 0, 'V', '<=', 'TOPRICE', '', 'Tu muc gia phai nho hon den muc gia!', 'The from price must less than to price!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('TICKSIZE', 'SA.SECURITIES_TICKSIZE', 1, 'V', '>>', '@0', '', 'Buoc gia phai lon hon 0!', 'The ticksize should greater than 0!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('FROMPRICE', 'SA.SECURITIES_TICKSIZE', 2, 'V', '>=', '@0', '', 'Tu gia phai lon hon 0!', 'The from price is not less than 0!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('TOPRICE', 'SA.SECURITIES_TICKSIZE', 3, 'V', '>>', '@0', '', 'Den gia phai lon hon 0!', 'The to price is not less than 0!', '', '', 0);COMMIT;