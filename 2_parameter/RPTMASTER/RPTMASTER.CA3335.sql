SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3335','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CA3335', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'Gửi điện xác nhận danh sách lên VSD (GD 3335)', 'Y', 1, '1', 'P', 'CA3335', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'Send the verification list to VSD(Tran 3335)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;