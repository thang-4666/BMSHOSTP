SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0049_1','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('OD0049_1', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'DANH SÁCH ĐẶT LỆNH QUA USER MÔI GIỚI', 'Y', 1, '1', 'L', 'OD0049_1', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'DANH SÁCH ĐẶT LỆNH QUA USER MÔI GIỚI', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;