SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('LN1005','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('LN1005', 'HOST', 'LN', '12', '5', '5', '60', '5', '5', 'BÁO CÁO DANH SÁCH HỢP ĐỘNG ĐƯỢC GIA HẠN MARGIN', 'Y', 1, '1', 'L', 'LN1005', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO DANH SÁCH HỢP ĐỘNG ĐƯỢC GIA HẠN MARGIN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;