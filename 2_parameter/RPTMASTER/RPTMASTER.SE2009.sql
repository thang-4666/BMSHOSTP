SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2009','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE2009', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO THỂ HIỆN CK PHÁT SINH TỪ QUYỀN CHUYỂN KHOẢN RA NGOÀI', 'Y', 1, '1', 'L', 'SE2009#SE200901#SE200902', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO THỂ HIỆN CK PHÁT SINH TỪ QUYỀN CHUYỂN KHOẢN RA NGOÀI', '', 0, 0, 0, 0, 'Y', 'N', 'Y', '');COMMIT;