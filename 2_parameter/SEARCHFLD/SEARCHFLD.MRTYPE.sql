SET DEFINE OFF;DELETE FROM SEARCHFLD WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MRTYPE','NULL');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (0, 'ACTYPE', 'Mã loại hình', 'C', 'MRTYPE', 100, '9999', 'LIKE,=', '_', 'Y', 'Y', 'Y', 100, '', 'Product type', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (1, 'TYPENAME', 'Tên loại hình', 'C', 'MRTYPE', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 150, '', 'Product name', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (2, 'STATUS', 'Trạng thái', 'C', 'MRTYPE', 100, '', '=', '', 'Y', 'Y', 'N', 200, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''SY'' AND CDNAME = ''YESNO'' ORDER BY LSTODR', 'Status', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'NOTES', 'Diễn giải', 'C', 'MRTYPE', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 300, '', 'Description', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (5, 'APPRV_STS', 'Trạng thái duyệt', 'C', 'MRTYPE', 100, '', '=', '', 'Y', 'Y', 'N', 200, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''SY'' AND CDNAME = ''APPRV_STS'' ORDER BY LSTODR', 'Apprv Status', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (100, 'EDITALLOW', 'Cho phép sửa?', 'C', 'MRTYPE', 100, '', 'LIKE,=', '', 'N', 'Y', 'N', 100, '', 'Edit Allow', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (100, 'APRALLOW', 'Cho phép duyệt?', 'C', 'MRTYPE', 100, '', 'LIKE,=', '', 'N', 'Y', 'N', 100, '', 'Aprove Allow', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (100, 'DELALLOW', 'Cho phép xóa?', 'C', 'MRTYPE', 100, '', 'LIKE,=', '', 'N', 'Y', 'N', 100, '', 'Delete Allow', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');COMMIT;