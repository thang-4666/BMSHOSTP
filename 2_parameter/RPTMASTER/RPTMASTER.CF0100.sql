SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0100','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CF0100', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'XÓA BIỂU PHÍ ƯU ĐÃI RIÊNG CHO KHÁCH HÀNG', 'Y', 1, '1', 'P', 'CF0100', 'N', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'ODPROBRKAF', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;