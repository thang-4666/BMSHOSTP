SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE8879','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE8879', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'THANH TOÁN CHỨNG KHOÁN GIAO DỊCH BÁN CHỨNG KHOÁN LÔ LẺ (GIAO DỊCH 8879)', 'Y', 1, '1', 'P', 'SSE', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'MATCH SECURITIES ORDER RETAIL (WAIT FOR 8878)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;