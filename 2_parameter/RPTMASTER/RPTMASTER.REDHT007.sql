SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('REDHT007','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('REDHT007', 'HOST', 'RE', '12', '5', '5', '60', '5', '5', 'PHỤ LỤC 05: DANH SÁCH 5 ĐHTGD XUẤT SẮC NHẤT THÁNG', 'Y', 1, '1', 'P', 'REDHT007', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'PHỤ LỤC 05: DANH SÁCH 5 ĐHTGD XUẤT SẮC NHẤT THÁNG', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;