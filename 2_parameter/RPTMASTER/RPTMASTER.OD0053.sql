SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0053','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('OD0053', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'BÁO CÁO GDCK THEO LOẠI CK KIÊM BẢNG KÊ PHÍ MÔI GIỚI PHÁT SINH THEO NGÀY', 'Y', 1, '1', 'L', 'OD0053', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO GDCK THEO LOẠI CK KIÊM BẢNG KÊ PHÍ MÔI GIỚI PHÁT SINH THEO NGÀY', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;