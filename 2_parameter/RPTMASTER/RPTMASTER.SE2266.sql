SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2266','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE2266', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'TRA CỨU XÁC NHẬN CHUYỂN KHOẢN CHỨNG KHOÁN RA NGOÀI (GIAO DỊCH 2266)', 'Y', 1, '1', 'P', 'SE2266', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW SENDING ACCOUNT TO OUTWARD TRANSFER (WAIT FOR 2266)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;