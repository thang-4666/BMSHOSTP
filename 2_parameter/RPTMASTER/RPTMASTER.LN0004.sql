SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('LN0004','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('LN0004', 'HOST', 'LN', '12', '5', '5', '60', '5', '5', 'BÁO CÁO PHÁT SINH VAY VÀ THU HỒI BẢO LÃNH', 'Y', 1, '1', 'L', 'LN0004', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO PHÁT SINH VAY VÀ THU HỒI BẢO LÃNH', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;