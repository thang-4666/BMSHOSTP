SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('RE.RETYPE','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('ODFEERATE', 'RE.RETYPE', 3, 'V', '>=', '@0', '', 'Tỷ lệ phí giao dịch không nhỏ hơn 0!', 'Order fee rate cannot less than 0!', '', '', 0);COMMIT;