SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('0382','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('05', '0382', 0, 'V', '>=', '<$BUSDATE>', '', 'Từ ngày phải lớn hơn hay bằng ngày hiện tại!', 'The value date must be greater than current date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('05', '0382', 1, 'V', '<=', '06', '', 'Từ ngày phải nhỏ hơn hay bằng đến ngày!', 'From date should be smaller or equal to to date!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('09', '0382', 6, 'E', '&&', '02&&07', '', '', '', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('10', '0382', 7, 'V', '>=', '@0', '', 'Giá trị điều chỉnh phải lớn hơn hoặc bằng 0', 'Adjust value must be greater than zero.', '', '', 0);COMMIT;