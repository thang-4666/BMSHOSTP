SET DEFINE OFF;DELETE FROM FLDVAL WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF.CFEXTACCT','NULL');Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('ISSUERID', 'CF.CFEXTACCT', 10, 'E', 'FX', 'FN_GET_ISSUERID', 'CODEID', '', '', '', '', 0);Insert into FLDVAL   (FLDNAME, OBJNAME, ODRNUM, VALTYPE, OPERATOR, VALEXP, VALEXP2, ERRMSG, EN_ERRMSG, TAGFIELD, TAGVALUE, CHKLEV) Values   ('TRANSFERAGENT', 'CF.CFEXTACCT', 10, 'E', 'FX', 'FN_GET_TRANSFERAGENT', 'CODEID', '', '', '', '', 0);COMMIT;