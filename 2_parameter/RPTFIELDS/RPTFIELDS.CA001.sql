SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CA001','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('STV', 'CACODE', 'CA001', 'CACODE', 'Thông tin quyền', 'CA info', 1, 'M', 'ccccccccccccccc', '_', 10, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', 'VSDID', 'CAMASTVSD', 'ST', '', '', '', '', 'Y', 'T', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('STV', 'BRID', 'CA001', 'BRID', 'Sàn giao dịch', 'Trade place', 2, 'M', '', '_', 10, 'select CDVAL VALUE, CDVAL VALUECD,CDCONTENT DISPLAY, EN_CDCONTENT EN_DISPLAY from allcode where cdname = ''TRADEPLACE'' and cduser = ''Y''
and cdtype = ''ST''', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', '', '', '', '', '', '', 'Y', 'C', 'N');COMMIT;