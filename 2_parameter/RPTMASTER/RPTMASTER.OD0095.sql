SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0095','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('OD0095', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TÌNH HÌNH GIAO DỊCH CỦA TÀI KHOẢN ONLINE', 'Y', 1, '1', 'L', 'OD0095', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO TÌNH HÌNH GIAO DỊCH CỦA TÀI KHOẢN ONLINE', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;