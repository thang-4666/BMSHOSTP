SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('GL1006','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('GL1006', 'HOST', 'GL', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TỔNG HỢP DOANH SỐ THEO NHÂN VIÊN MÔI GIỚI (VIP TEAM)', 'Y', 1, '1', 'L', 'GL1006', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO TỔNG HỢP DOANH SỐ THEO NHÂN VIÊN MÔI GIỚI (VIP TEAM)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;