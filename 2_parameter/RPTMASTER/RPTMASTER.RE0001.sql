SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RE0001','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('RE0001', 'HOST', 'RE', '12', '5', '5', '60', '5', '5', 'TRA CỨU KHÁCH HÀNG CỦA MÔI GIỚI', 'Y', 1, '1', 'P', 'RE0001', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW CUSTOMER BELONG TO REMISER TO REMISER', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;