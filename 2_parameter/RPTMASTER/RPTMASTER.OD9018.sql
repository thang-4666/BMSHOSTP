SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD9018','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('OD9018', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'XÓA LỆNH KHỚP HNX  ', 'Y', 1, '1', 'P', 'OD9018', 'Y', 'B', 'N', 'D', 'N', 'N', 'M', '000', 'S', -1, 'DELETE HA MATCHING ORDER (8813)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;