SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('DF0055','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('DF0055', 'HOST', 'DF', '12', '5', '5', '60', '5', '5', 'YÊU CẦU CHUYỂN KHOẢN CẦM CỐ CHỨNG KHOÁN VỚI VSD - 29/LK', 'Y', 1, '1', 'L', 'DF0055', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'YÊU CẦU CHUYỂN KHOẢN CẦM CỐ CHỨNG KHOÁN VỚI VSD ', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;