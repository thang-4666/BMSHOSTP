SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RM6650','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('RM6650', 'HOST', 'RM', '12', '5', '5', '60', '5', '5', 'Thông báo đăng ký mã chứng khoán mới', 'Y', 1, '1', 'P', '', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'Notice of new stock code registration', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;