SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2222','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE2222', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'ĐIỀU CHỈNH GIÁ VỐN CHỨNG KHOÁN (GIAO DỊCH 2222)', 'Y', 1, '1', 'P', '', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW SECURITIES ACCOUNT TO ADJUST COSTPRICE (WAIT FOR 2222)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;