SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('2626','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('02', '2626', 1, 'I', 'FX', 'FNC_CHECK_TLTXCD_SCOPE', '02##BR##TL##TX', 'NSD không có quyền thực hiện cho khách hàng', 'NSD kh�c�y?n th?c hi?n cho kh� h�', '', '', 0);COMMIT;