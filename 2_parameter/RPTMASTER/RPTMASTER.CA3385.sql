SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3385','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('CA3385', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'DS KH CHỜ NHẬN CHUYỂN NHƯỢNG QUYỀN MUA(GIAO DỊCH 3385)', 'Y', 1, '1', 'P', 'CA3385', 'N', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'TRANSFER (3385)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;