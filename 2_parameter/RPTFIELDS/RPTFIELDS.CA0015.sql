SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('CA0015','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('CA', 'CACODE', 'CA0015', 'CACODE', 'Mã sự kiện CA', 'CA Code', 1, 'M', 'cccc.cccccc.cccccc', '_', 20, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', 'CAMAST', 'CA', '', '', '', '', 'Y', 'T', 'N');COMMIT;