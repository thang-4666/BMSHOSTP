SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('DF0019','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('DF0019', 'HOST', 'DF', '12', '5', '5', '60', '5', '5', 'BẢNG KÊ CHI TIẾT NỢ CHƯA THANH LÝ DEAL', 'Y', 1, '1', 'L', 'DF0019', 'N', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BẢNG KÊ CHI TIẾT NỢ CHƯA THANH LÝ DEAL', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;