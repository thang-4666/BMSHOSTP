SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE0065','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE0065', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO PHÁT SINH TIỀN MUA CHỨNG KHOÁN GIAO DỊCH LÔ LẺ', 'Y', 1, '1', 'L', 'SE0065', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BÁO CÁO PHÁT SINH TIỀN MUA CHỨNG KHOÁN GIAO DỊCH LÔ LẺ', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;