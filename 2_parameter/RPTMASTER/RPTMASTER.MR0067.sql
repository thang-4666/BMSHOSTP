SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('MR0067','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('MR0067', 'HOST', 'MR', '12', '5', '5', '60', '5', '5', 'BÁO CÁO THAY ĐỔI HẠN MỨC CHỨNG KHOÁN VÀ GÁN KHÁCH HÀNG CHO NHÓM KHÁCH HÀNG ĐẶC BIỆT', 'Y', 1, '1', 'P', 'MR0067', 'N', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO THAY ĐỔI HẠN MỨC CHỨNG KHOÁN VÀ GÁN KHÁCH HÀNG CHO NHÓM KH ĐẶC BIỆT', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;