SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('5078','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('10', '5078', 0, 'V', '>=', '@0', '', 'Gia tri hop dong phai lon hon 0!', 'Contract value cannot less than 0!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('14', '5078', 0, 'V', '>>', '@0', '', 'Kỳ hạn repo phải lớn hơn 0!', 'Tern repo should be greater than zero!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('11', '5078', 1, 'V', '>=', '@0', '', 'Ty le ky quy phai lon hon 0!', 'Guarantee ratio cannot less than 0!', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('11', '5078', 2, 'V', '<=', '@1', '', 'Ty le ky quy phai nho hon 1!', 'Guarantee ratio cannot greater than 1!', '', '', 0);COMMIT;