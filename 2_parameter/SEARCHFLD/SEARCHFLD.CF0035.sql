SET DEFINE OFF;DELETE FROM SEARCHFLD WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0035','NULL');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (0, 'AUTOID', 'STT', 'C', 'CF0035', 10, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'AUTOID', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (1, 'FULLNAME', 'Họ và tên', 'C', 'CF0035', 100, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'FULLNAME', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (2, 'IDCODE', 'Số ĐKSH', 'C', 'CF0035', 50, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'IDCODE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'IDDATE', 'Ngày cấp', 'D', 'CF0035', 80, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'IDDATE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (4, 'IDPLACE', 'Nơi cấp', 'C', 'CF0035', 100, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'IDPLACE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (5, 'CUSTODYCD', 'Mã tài khoản giao dịch', 'C', 'CF0035', 70, 'U', 'LIKE,=', 'N', 'Y', 'Y', 'Y', 100, '', 'CUSTODYCD', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (6, 'IDTYPE', 'Loại ĐKSH', 'C', 'CF0035', 4, 'U', 'LIKE,=', 'N', 'Y', 'Y', 'N', 50, '', 'IDTYPE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (7, 'CUSTTYPE', 'Loại hình cổ đông', 'C', 'CF0035', 4, 'U', 'LIKE,=', 'N', 'Y', 'Y', 'N', 50, '', 'CUSTTYPE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'COUNTRY', 'Quốc tịch', 'C', 'CF0035', 4, 'U', 'LIKE,=', 'N', 'Y', 'Y', 'N', 100, '', 'COUNTRY', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (9, 'ADDRESS', 'Địa chỉ', 'C', 'CF0035', 90, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'ADDRESS', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (10, 'MOBILE', 'Điện thoại', 'C', 'CF0035', 70, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'MOBILE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (11, 'EMAIL', 'Email', 'C', 'CF0035', 70, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'EMAIL', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (12, 'DESCRIPTION', 'Ghi chú', 'C', 'CF0035', 70, 'U', 'LIKE,=', 'N', 'Y', 'N', 'N', 100, '', 'DESCRIPTION', 'N', '', '', 'N', '', '', '', 'N', 'N', 'N');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (13, 'OPNDATE', 'Ngày mở TK', 'D', 'CF0035', 80, 'U', 'LIKE,=', 'N', 'N', 'Y', 'N', 100, '', 'OPNDATE', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (14, 'PV_CLASS', 'TK chuyên dụng', 'C', 'CF0035', 100, '', 'Like,=', '', 'N', 'Y', 'N', 100, 'SELECT ''Không'' VALUE, ''Không'' DISPLAY, 0 LSTODR FROM DUAL
UNION ALL  SELECT ''Có'' VALUE, ''Có'' DISPLAY, 1 LSTODR FROM DUAL
ORDER BY LSTODR', 'Account type', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');COMMIT;