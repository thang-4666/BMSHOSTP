SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI0042','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI0042', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TỔNG HỢP TIỀN ỨNG TRƯỚC VÀ MARGIN', 'Y', 1, '1', 'P', 'CI0042', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO TỔNG HỢP TIỀN ỨNG TRƯỚC VÀ MARGIN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;