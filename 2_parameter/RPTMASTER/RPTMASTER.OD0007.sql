SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0007','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('OD0007', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'KẾT QUẢ KHỚP LỆNH', 'Y', 1, '1', 'P', 'OD0007', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'KẾT QUẢ KHỚP LỆNH', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;