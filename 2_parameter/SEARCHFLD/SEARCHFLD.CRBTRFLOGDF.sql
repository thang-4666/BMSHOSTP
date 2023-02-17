SET DEFINE OFF;DELETE FROM SEARCHFLD WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CRBTRFLOGDF','NULL');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (0, 'AUTOID', 'Mã quản lý', 'N', 'CRBTRFLOGDF', 80, '', '=', '', 'N', 'N', 'Y', 80, '', 'AutoID', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (1, 'TXDATE', 'Ngày', 'D', 'CRBTRFLOGDF', 80, '', '>=,<=,=', '', 'Y', 'Y', 'N', 100, '', 'Date', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (2, 'AFFECTDATE', 'Ngày hiệu lực', 'D', 'CRBTRFLOGDF', 80, '', '>=,<=,=', '', 'Y', 'Y', 'N', 100, '', 'Affect Date', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'VERSION', 'Số TT', 'C', 'CRBTRFLOGDF', 60, '', 'LIKE,=', '', 'N', 'Y', 'N', 100, '', 'Version', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (4, 'VOUCHERNO', 'Số bảng kê', 'C', 'CRBTRFLOGDF', 150, '', 'LIKE,=', '', 'Y', 'N', 'N', 150, '', 'Voucher No', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (5, 'DESC_TRFCODE', 'Loại', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'Y', 'Y', 'N', 120, '', 'Type', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (6, 'REFBANK', 'Tham chiếu', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Bank', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (7, 'DESC_STATUS', 'Trạng thái', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Status', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'ERRDESC', 'Diễn giải lỗi', 'C', 'CRBTRFLOGDF', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Error description', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (9, 'CREATETST', 'Thời điểm tạo', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Created time', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (10, 'SENDTST', 'Thời điểm nhận', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Sent time', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (11, 'APRALLOW', 'Được duyệt không', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'N', 'N', 'N', 100, '', 'Allow approve', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (12, 'EDITALLOW', 'Được sửa không', 'C', 'CRBTRFLOGDF', 80, '', 'LIKE,=', '', 'N', 'N', 'N', 100, '', 'Allow modify', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');COMMIT;