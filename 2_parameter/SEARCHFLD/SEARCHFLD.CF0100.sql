SET DEFINE OFF;DELETE FROM SEARCHFLD WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0100','NULL');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (-1, 'AUTOID', 'Mã tự tăng', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'N', 'Y', 'Y', 100, '', 'Afacctno', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (0, 'AFACCTNO', 'Mã tiểu khoản', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Afacctno', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (2, 'CUSTODYCD', 'Số lưu ký', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Custodycd', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'ODNAME', 'Tên chính sách', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 300, '', 'ODNAME', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'REFAUTOID', 'Mã chính sách', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'REFAUTOID', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (4, 'FULLNAME', 'Tên khách hàng', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 150, '', 'Fullname', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (5, 'STATUS', 'Trạng thái', 'C', 'CF0100', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Status', 'Y', '', '', 'N', '', '', '', 'N', 'N', 'Y');COMMIT;