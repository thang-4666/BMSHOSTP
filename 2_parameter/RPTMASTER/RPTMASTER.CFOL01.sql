SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CFOL01','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CFOL01', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'Danh sách khách hàng khác Cá nhân Việt Nam mở trực tuyến', 'Y', 1, '1', 'P', 'CFOL01', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'List of other customers Vietnamese individuals open online', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;