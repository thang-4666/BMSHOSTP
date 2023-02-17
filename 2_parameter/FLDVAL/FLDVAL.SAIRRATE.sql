SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.IRRATE','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('RATE', 'SA.IRRATE', 0, 'V', '>=', '@0', '', 'Lãi suất cơ sở phải >= 0!', 'Based rate should be greater than or equal to zero!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('FLRRATE', 'SA.IRRATE', 1, 'V', '>>', '@0', '', 'Lãi suất sàn phải lớn hơn 0!', 'Floor rate should be greater than or equal to zero!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('CELRATE', 'SA.IRRATE', 2, 'V', '>>', 'FLRRATE', '', 'Lãi suất trần phải lớn hơn lãi suất sàn!', 'Ceiling rate should be greater than or equal to Floor rate!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('TODATE', 'SA.IRRATE', 3, 'V', '>>', 'EFFECTIVEDT', '', 'Ngày hết hiệu lực phải lớn hơn ngày hiệu lực!', 'ToDate should be greater than or equal to Effective date!', '', '', 0);COMMIT;