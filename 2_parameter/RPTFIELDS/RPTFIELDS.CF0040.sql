SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CF0040','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('CF', 'CUSTODYCD', 'CF0040', 'CUSTODYCD', 'Số TK lưu ký', 'Custody code', 1, 'M', 'cccc.cccccc', 'cccc.cccccc', 10, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', 'CUSTODYCD', '##########', '', 'CUSTODYCD_CF', 'CF', '', '', '', '', 'N', 'T', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('CF', 'AFACCTNO', 'CF0040', 'AFACCTNO', 'Số tiểu khoản', 'Sub account', 3, 'M', '9999.999999', '9999.999999', 30, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', 'AFACCTNO', '##########', '', 'CIMAST_ALL', 'CF', '', 'CUSTODYCD', 'SELECT FILTERCD, VALUE, VALUECD, DISPLAY, EN_DISPLAY, DESCRIPTION FROM VW_CUSTODYCD_SUBACCOUNT_ACTIVE WHERE FILTERCD=''<$TAGFIELD>'' ORDER BY VALUE', '', 'Y', 'C', 'N');COMMIT;