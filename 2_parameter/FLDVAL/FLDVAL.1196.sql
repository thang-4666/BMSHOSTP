SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('1196','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('10', '1196', 0, 'V', '>>', '@0', '', 'Số tiền phải lớn hơn 0', 'Amount should be greater than zero', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('82', '1196', 1, 'I', 'FX', 'FNC_CHECK_TLTXCD_SCOPE', '82##BR##TL##TX', 'NSD không có quyền thực hiện cho khách hàng', 'NSD không có quyền thực hiện cho khách hàng', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('82', '1196', 5, 'I', 'FX', 'cspks_cfproc.fn_checkNonCustody', '82', 'Tài khoản phải lưu ký tại cong ty', 'Tai khoan phai luu ky tai cong ty', '', '', 0);COMMIT;