SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('LN5573','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('LN5573', 'HOST', 'LN', '12', '5', '5', '60', '5', '5', 'GIA HẠN CHO MỘT DEAL', 'Y', 1, '1', 'P', 'LN5573', 'N', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW ACCOUNT TRANSFER TO OTHER ACCOUNT(WAIT FOR 5573)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;