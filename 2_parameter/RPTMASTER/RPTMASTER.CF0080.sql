SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0080','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CF0080', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'GIẤY ĐỀ NGHỊ TẤT TOÁN ', 'Y', 1, '1', 'P', 'CF0080#CF0081', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'GIẤY ĐỀ NGHỊ TẤT TOÁN', '', 0, 0, 0, 0, 'Y', 'N', 'Y');COMMIT;