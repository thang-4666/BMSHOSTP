SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RE0014','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('RE0014', 'HOST', 'RE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO THAY ĐỔI MÔI GIỚI CHĂM SÓC KHÁCH HÀNG', 'Y', 1, '1', 'P', 'RE0014', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO THAY ĐỔI MÔI GIỚI CHĂM SÓC KHÁCH HÀNG', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;