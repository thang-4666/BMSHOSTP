SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('ST9942','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('ST9942', 'HOST', 'ST', '12', '5', '5', '60', '5', '5', 'Tra cứu điện thông báo từ VSD (564)', 'Y', 1, '1', 'P', 'ST9942', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'Manage notification messages from VSD (564)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;