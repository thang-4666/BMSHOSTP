SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA009','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('CA009', 'HOST', 'STV', '12', '5', '5', '60', '5', '5', 'Danh sách người sở hữu chứng khoán lưu ký nhận cổ tức bằng tiền', 'N', 1, '1', 'P', 'MTREPORT', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'M', -1, 'The general list of securities holders receiving dividend in cash', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;