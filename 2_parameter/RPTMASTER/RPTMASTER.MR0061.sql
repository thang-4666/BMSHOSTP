SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('MR0061','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('MR0061', 'HOST', 'MR', '12', '5', '5', '60', '5', '5', 'BÁO CÁO CHI TIẾT CHỨNG KHOÁN MARGIN SỞ HỮU', 'Y', 1, '1', 'P', 'MR0061', 'N', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO CHI TIẾT CHỨNG KHOÁN MARGIN SỞ HỮU', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;