SET DEFINE OFF;DELETE FROM RPTFIELDS WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('OD0091','NULL');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('OD', 'I_DATE', 'OD0091', 'I_DATE', 'Ngày giao dịch', 'To date', 1, 'M', '99/99/9999', 'DD/MM/YYYY', 10, '', '', '<$BUSDATE>', 'Y', 'N', 'Y', '', '', 'N', 'D', '', '', '', '', '', '', '', '', '', '', '', '', 'Y', 'T', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('OD', 'PV_CUSTODYCD', 'OD0091', 'PV_CUSTODYCD', 'Số lưu ký ', 'Custody code', 2, 'M', 'cccc.cccccc', '_', 10, '', '', '', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', 'CUSTODYCD_TX', 'CF', '', '', '', '', 'Y', 'T', 'N');Insert into RPTFIELDS   (MODCODE, FLDNAME, OBJNAME, DEFNAME, CAPTION, EN_CAPTION, ODRNUM, FLDTYPE, FLDMASK, FLDFORMAT, FLDLEN, LLIST, LCHK, DEFVAL, VISIBLE, DISABLE, MANDATORY, AMTEXP, VALIDTAG, LOOKUP, DATATYPE, INVNAME, FLDSOURCE, FLDDESC, CHAINNAME, PRINTINFO, LOOKUPNAME, SEARCHCODE, SRMODCODE, INVFORMAT, TAGFIELD, TAGLIST, TAGVALUE, ISPARAM, CTLTYPE, CHKSCOPE) Values   ('OD', 'NOIIN', 'OD0091', 'NOIIN', 'Nơi in', 'NOIIN', 4, 'M', 'cccccccc', '_', 20, 'SELECT ''HN'' VALUE, ''HN'' VALUECD, ''HÀ NỘI'' DISPLAY, ''HÀ NỘI'' EN_DISPLAY FROM DUAL
UNION ALL
SELECT ''HCM'' VALUE, ''HCM'' VALUECD, ''HỒ CHÍ MINH'' DISPLAY, ''HỒ CHÍ MINH'' EN_DISPLAY FROM DUAL
UNION ALL
SELECT ''HCMVAT'' VALUE, ''HCMVAT'' VALUECD, ''HỒ CHÍ MINH - Có thuế nhà thầu'' DISPLAY, ''HỒ CHÍ MINH - Có thuế nhà thầu'' EN_DISPLAY FROM DUAL', '', 'HÀ NỘI', 'Y', 'N', 'Y', '', '', 'N', 'C', '', '', '', '', '', '', '', '', '', '', '', '', 'Y', 'C', 'N');COMMIT;