SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0028','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('OD0028', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TÌNH HÌNH GIAO DỊCH THEO MÃ CHỨNG KHOÁN ', 'Y', 1, '1', 'L', 'OD0028', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO TÌNH HÌNH GIAO DỊCH THEO MÃ CHỨNG KHOÁN ', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;