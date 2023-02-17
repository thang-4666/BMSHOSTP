SET DEFINE OFF;DELETE FROM FLDMASTER WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('RE.REMAST','NULL');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'ACCTNO', 'RE.REMAST', 'ACCTNO', 'Mã khách hàng', 'Account number', 1, 'C', '9999.999999', '9999.999999', 10, '', '', '', 'Y', 'Y', 'Y', '', '', 'N', 'C', 'REACCTNO', '', '', '', '', '', '', '', '<$BRID>[000000]', 'M', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'ACTYPE', 'RE.REMAST', 'ACTYPE', 'Mã loại hình', 'Product', 0, 'C', '9999', '9999', 4, 'SELECT ACTYPE VALUECD, ACTYPE VALUE, TYPENAME DISPLAY,
TYPENAME EN_DISPLAY, TYPENAME DESCRIPTION, RATECOMM FROM
RETYPE WHERE APPRV_STS = ''A''', '', '', 'Y', 'N', 'Y', '', '', 'Y', 'C', '', '', '', '', '', '', '', '', '', 'M', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'BALANCE', 'RE.REMAST', 'BALANCE', 'Số dư', 'Balance', 5, 'T', '', '#,##0', 20, '', '', '0', 'Y', 'Y', 'Y', '', '', 'N', 'N', '', '', '', '', '', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'N', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'CUSTID', 'RE.REMAST', 'CUSTID', 'Môi giới', 'Broker/Remiser', 2, 'C', '9999.999999', '9999.999999', 10, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', 'CFMAST_RE', 'CF', '', 'M', 'N', 'MAIN', '', '', '', 'N', '', 'Y', '', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'DIRECTACR', 'RE.REMAST', 'DIRECTACR', 'Doanh thu trực tiếp', 'Direct amount', 9, 'T', '', '#,##0', 20, '', '', '0', 'Y', 'Y', 'Y', '', '', 'N', 'N', '', '', '', '', '', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'N', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'INDIRECTACR', 'RE.REMAST', 'INDIRECTACR', 'Doanh thu gián tiếp', 'InDirect', 10, 'T', '', '#,##0', 20, '', '', '0', 'Y', 'Y', 'Y', '', '', 'N', 'N', '', '', '', '', '', '', '', '', '', 'T', 'N', 'MAIN', '', '', '', 'N', '', 'N', '0', 'N', '', '', '', 'N');Insert into FLDMASTER   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, CTLTYPE, RISKFLD, GRNAME, TAGFIELD, TAGVALUE, TAGLIST, TAGQUERY, PDEFNAME, TAGUPDATE, FLDRND, SUBFIELD, PDEFVAL, DEFDESC, DEFPARAM, CHKSCOPE) Values   ('RE', 'STATUS', 'RE.REMAST', 'STATUS', 'Trạng thái', 'Status', 4, 'C', '', '', 3, 'SELECT  CDVAL VALUECD, CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''RE'' AND CDNAME = ''STATUS'' ORDER BY LSTODR', '', 'P', 'Y', 'Y', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', '', '', '', 'C', 'Y', 'MAIN', '', '', '', 'N', '', 'Y', '', 'N', '', '', '', 'N');COMMIT;