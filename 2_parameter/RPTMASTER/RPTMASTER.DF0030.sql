SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('DF0030','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('DF0030', 'HOST', 'DF', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TỔNG HỢP GIẢI NGÂN THANH LÝ SẢN PHẨM', 'Y', 1, '1', 'L', 'DF0030', 'N', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO TỔNG HỢP GIẢI NGÂN THANH LÝ SẢN PHẨM', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;