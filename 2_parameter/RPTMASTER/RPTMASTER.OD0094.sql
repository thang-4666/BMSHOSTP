SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0094','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('OD0094', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'THÔNG BÁO KẾT QUẢ GIAO DỊCH MUA CHỨNG KHOÁN(TIẾNG ANH)', 'Y', 1, '1', 'L', 'OD0092', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'THÔNG BÁO KẾT QUẢ GIAO DỊCH MUA CHỨNG KHOÁN (TIẾNG ANH)', '', 0, 0, 0, 0, 'Y', 'N', 'Y', '');COMMIT;