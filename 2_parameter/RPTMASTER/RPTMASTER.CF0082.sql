SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0082','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('CF0082', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'BMSC - BÁO CÁO TÀI KHOẢN ĐĂNG KÝ ỨNG TRƯỚC BÊN THỨ 3', 'Y', 1, '1', 'P', 'CF0082', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'VCBS - BÁO CÁO TÀI KHOẢN ĐĂNG KÝ ỨNG TRƯỚC BÊN THỨ 3', '', 0, 0, 0, 0, 'Y', 'N', 'Y', '');COMMIT;