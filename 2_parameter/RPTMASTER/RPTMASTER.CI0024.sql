SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI0024','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI0024', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'HỢP ĐỒNG MUA BÁN QUYỀN NHẬN TIỀN BÁN CHỨNG KHOÁN', 'Y', 1, '1', 'P', 'CI0024#CI00241', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'HỢP ĐỒNG MUA BÁN QUYỀN NHẬN TIỀN BÁN CHỨNG KHOÁN', '', 0, 0, 0, 0, 'Y', 'N', 'Y');COMMIT;