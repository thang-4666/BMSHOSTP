SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0001_1','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CF0001_1', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'BÁO CÁO DANH SÁCH KH ĐĂNG KÝ GD TRỰC TUYẾN VÀ ĐIỆN THOẠI', 'Y', 1, '1', 'L', 'CF0001_1', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO DANH SÁCH KH ĐĂNG KÝ GD TRỰC TUYẾN VÀ ĐIỆN THOẠI', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;