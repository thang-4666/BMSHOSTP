SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('BO0001','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('BO0001', 'HOST', 'BO', '12', '5', '5', '60', '5', '5', 'THEO DÕI MUA BÁN THỨ CẤP', 'Y', 1, '1', 'P', '', 'N', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'THEO DÕI MUA BÁN THỨ CẤP', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;