SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('SE0093','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('SE', 'I_DATE', 'SE0093', 'I_DATE', 'Tại ngày', 'On date', 1, 'M', '99/99/9999', 'dd/MM/yyyy', 10, '', '', '<$BUSDATE>', 'Y', 'N', 'Y', '', '', 'N', 'D', '', '', '', '', '', '', '', '', '', '', '', '', 'Y', '', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('SE', 'SYMBOL', 'SE0093', 'SYMBOL', 'Mã trái phiếu', 'Symbol', 2, 'M', 'ccccccccccccccccccccccc', '_', 30, 'SELECT SYMBOL VALUE, SYMBOL VALUECD, fullname DISPLAY, SYMBOL EN_DISPLAY, SYMBOL DESCRIPTION FROM (SELECT SYMBOL,IR.fullname ,1 LSTODR FROM SBSECURITIES SB,ISSUERS IR WHERE IR.ISSUERID =SB.issuerid and  sb.TRADEPLACE IN (''003'') order by sb.SYMBOL)', '', '', 'Y', 'N', 'Y', '', '', 'Y', 'C', '', '', '', '', '', '', '', '', '', '', '', '', 'Y', 'T', 'N');COMMIT;