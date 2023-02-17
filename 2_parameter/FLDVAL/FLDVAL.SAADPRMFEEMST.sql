SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SA.ADPRMFEEMST','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('FEERATE', 'SA.ADPRMFEEMST', 0, 'V', '>=', '@0', '', 'Tỷ lệ phí không nhỏ hơn 0!', 'The fee rate can not less than 0!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('OPENDATE', 'SA.ADPRMFEEMST', 4, 'V', '<=', 'CLOSEDATE', '', 'Ngày kết thúc khai báo phải sau ngày bắt đầu khai báo!', 'The expired date is invalid!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('VALDATE', 'SA.ADPRMFEEMST', 4, 'V', '<=', 'EXPDATE', '', 'Ngày hết hạn phải sau ngày có hiệu lực!', 'The expired date is invalid!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('CLOSEDATE', 'SA.ADPRMFEEMST', 5, 'V', '>=', '@<$BUSDATE>', '', 'Ngày kết thúc khai báo lớn hơn hay bằng ngày hiện tại!', 'The expired date must be greater than current date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('EXPDATE', 'SA.ADPRMFEEMST', 5, 'V', '>=', '@<$BUSDATE>', '', 'Ngày hết hạn lớn hơn hay bằng ngày hiện tại!', 'The expired date must be greater than current date!', '', '', 0);COMMIT;