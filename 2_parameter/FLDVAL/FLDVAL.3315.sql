SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('3315','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('18', '3315', 1, 'V', '==', '<$WORKDATE>', '', 'Ngày giao dịch trở lại phải là ngày làm việc!', 'Trade date should be working date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('18', '3315', 2, 'V', '>=', '07', '', 'Ngày giao dịch trở lại phải sau ngày phân bổ!', 'Trade date should be greater than action date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('18', '3315', 3, 'V', '>=', '<$BUSDATE>', '', 'Ngày giao dịch trở lại phải lớn hơn ngày hiện tại!', 'Trade date must be greater than current date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('27', '3315', 5, 'E', 'FX', 'FN_SEQTTY_3315', '03', '', '', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('28', '3315', 5, 'E', 'FX', 'FN_CAQTTY_3315', '03', '', '', '', '', 0);COMMIT;