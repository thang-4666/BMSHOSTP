SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('RM0035','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('RM', 'AUTOID', 'RM0035', 'PV_AUTOID', 'Số AUTOID', 'AUTOID', 1, 'M', '9999999999', '9999999999', 10, '', '', 'ALL', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', 'RMNUMBERLIST_RPT', 'RM', '', '', '', '', 'Y', 'T', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('RM', 'PV_TXNUM', 'RM0035', 'PV_TXNUM', 'Số hiệu bảng kê', 'Version', 2, 'T', 'ccccccccccccccc', '_', 10, 'SELECT VERSION VALUE, VERSION DISPLAY, VERSION EN_DISPLAY, VERSION DISCRIPTION FROM vw_crbtrflog_all ORDER BY AUTOID', '', '', 'Y', 'Y', 'N', '', '', 'N', 'C', '', '', '', '', '', '', '', 'RM', '', 'AUTOID', 'SELECT DISTINCT VERSION  FILTERCD , VERSION VALUE, VERSION VALUECD, VERSION DISPLAY, VERSION EN_DISPLAY, VERSION DESCRIPTION  FROM vw_crbtrflog_all WHERE AUTOID = UPPER(''<$TAGFIELD>'')', '', 'Y', 'C', 'N');COMMIT;