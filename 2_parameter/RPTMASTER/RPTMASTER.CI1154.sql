SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI1154','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI1154', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'TRA CỨU ỨNG TRƯỚC TIỀN BÁN THEO NGUỒN', 'Y', 1, '1', 'P', 'CI1154', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'ADVANCED PAYMENT ALLOCATION RESOURCE', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;