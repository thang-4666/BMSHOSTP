SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2006','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE2006', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO THÔNG TIN TÀI SẢN TRÊN TÀI KHOẢN', 'Y', 1, '1', 'L', 'SE2006', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO THÔNG TIN TÀI SẢN TRÊN TÀI KHOẢN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;