SET DEFINE OFF;DELETE FROM FLDMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('0170','NULL');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('CF', '01', '0170', 'TXDATE', 'Ngày yêu cầu', 'Open Date', 2, 'C', '', '', 20, '', '', '', 'Y', 'Y', 'N', '', '', 'N', 'D', '', '', '', '', '##########', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('CF', '03', '0170', 'REQID', 'Mã yêu cầu', 'Request Id', 1, 'C', '', '', 100, ' ', ' ', ' ', 'Y', 'Y', 'Y', ' ', ' ', 'N', 'C', '', '', '', '', '##########', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('CF', '04', '0170', 'FULLNAME', 'Tên KH', 'Full name', 4, 'C', '', '', 500, ' ', ' ', ' ', 'Y', 'N', 'Y', ' ', ' ', 'N', 'C', '', '', '', '', '##########', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('CF', '80', '0170', 'CONFIRMSTATUS', 'Trạng thái xác nhận', 'Confirmation status', 3, 'C', '', '', 10, 'SELECT CDVAL VALUECD, CDVAL VALUE, CDCONTENT DISPLAY, EN_CDCONTENT EN_DISPLAY, EN_CDCONTENT DESCRIPTION
FROM ALLCODE WHERE CDNAME = ''CONFIRM_STATUS'' AND CDTYPE=''RM'' AND CDUSER=''Y''
ORDER BY LSTODR', '', 'CONF', 'Y', 'N', 'Y', ' ', ' ', 'Y', 'C', '', '', '', 'CONFIRMSTATUS', '##########', '', '', 'SA', '', 'C', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '0', 'N', '', '', '', 'N');COMMIT;