SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI0033','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI0033', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'BÁO CÁO TÍNH PHÍ CHI TIẾT CHO TỪNG TÀI KHOẢN ', 'Y', 1, '1', 'L', 'CI0033', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO TÍNH PHÍ CHI TIẾT CHO TỪNG TÀI KHOẢN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;