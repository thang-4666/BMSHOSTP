SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.AFPOLICYMAP','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('EXPDATE', 'CF.AFPOLICYMAP', 1, 'V', '>>', 'EFFDATE', '', 'Ngày hết hạn phải sau ngày có hiệu lực!', 'The expired date is invalid!', '', '', 0);COMMIT;