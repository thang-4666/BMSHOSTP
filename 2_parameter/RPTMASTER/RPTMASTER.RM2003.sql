SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RM2003','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('RM2003', 'HOST', 'RM', '12', '5', '5', '60', '5', '5', 'DANH SÁCH CÁC GIAO D?CH THU HỘ MUỘN LỖI (GD 1196)', 'Y', 1, '1', 'P', '', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'BANK TRANS LIST ERROR (1141)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;