SET DEFINE OFF;DELETE FROM SEARCHFLD WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ODER07','NULL');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (1, 'TXDATE', 'Ngày giao dịch', 'D', 'ODER07', 100, '', '<,<=,=,>=,>,<>', '', 'Y', 'Y', 'N', 100, '', 'Txdate', 'N', '08', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (2, 'ORDERID', 'Số hiệu lệnh', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'Y', 'Y', 120, '', 'OrderId', 'N', '01', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (3, 'CUSTODYCD', 'Số lưu ký', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Custody code', 'N', '02', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (4, 'AFACCTNO', 'Số tiểu khoản', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Afacctno', 'N', '03', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (5, 'CODEID', 'Mã code CK', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, '', 'Codeid', 'N', '07', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (6, 'SYMBOL', 'Mã chứng khoán', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'Symbol', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (7, 'EXECTYPEVL', 'Loại lệnh', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, '', 'Order type', 'N', '22', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'EXECTYPE', 'Loại lệnh', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''OD'' AND CDNAME = ''EXECTYPE'' ORDER BY LSTODR', 'Order type', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'FULLNAME', 'Tên', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''OD'' AND CDNAME = ''EXECTYPE'' ORDER BY LSTODR', 'Order type', 'N', '57', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'IDCODE', 'CMND/GPKD', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''OD'' AND CDNAME = ''EXECTYPE'' ORDER BY LSTODR', 'Order type', 'N', '59', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (8, 'ADDRESS', 'Địa chỉ', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'N', 'N', 'N', 100, 'SELECT CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = ''OD'' AND CDNAME = ''EXECTYPE'' ORDER BY LSTODR', 'Order type', 'N', '58', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (10, 'DFACCTNO', 'Số hiệu DF', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'Y', 'N', 100, '', 'DFACCTNO', 'N', '05', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (11, 'ORDERQTTY', 'Khối lượng đặt', 'N', 'ODER07', 100, '', '<,<=,=,>=,>,<>', '#,##0', 'Y', 'Y', 'N', 100, '', 'Order quantity', 'N', '10', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (12, 'QUOTEPRICE', 'Giá đặt', 'N', 'ODER07', 100, '', '<,<=,=,>=,>,<>', '#,##0', 'Y', 'Y', 'N', 100, '', 'Quote price', 'N', '11', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (13, 'MATCHQTTY', 'Khối lượng khớp', 'N', 'ODER07', 100, '', '<,<=,=,>=,>,<>', '#,##0', 'Y', 'Y', 'N', 100, '', 'Match quantity', 'N', '12', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (14, 'MATCHAMT', 'Giá trị khớp', 'N', 'ODER07', 100, '', '<,<=,=,>=,>,<>', '#,##0', 'Y', 'Y', 'N', 100, '', 'Match value', 'N', '14', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (15, 'CLEARDATE', 'Ngày thanh toán', 'D', 'ODER07', 100, '', '=', '', 'Y', 'Y', 'N', 100, '', 'Clear date', 'N', '09', '', 'N', '', '', '', 'N', 'N', 'Y');Insert into SEARCHFLD   (POSITION, FIELDCODE, FIELDNAME, FIELDTYPE, SEARCHCODE, FIELDSIZE, MASK, OPERATOR, FORMAT, DISPLAY, SRCH, KEY, WIDTH, LOOKUPCMDSQL, EN_FIELDNAME, REFVALUE, FLDCD, DEFVALUE, MULTILANG, ACDTYPE, ACDNAME, FIELDCMP, FIELDCMPKEY, CHKSCOPE, ISPROCESS) Values   (16, 'ERRREASON', 'Nguyên nhân lỗi', 'C', 'ODER07', 100, '', 'LIKE,=', '', 'Y', 'N', 'N', 120, '', 'Error reason', 'N', '', '', 'N', '', '', '', 'N', 'N', 'Y');COMMIT;