SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD8810','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('OD8810', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'DANH SÁCH LỆNH BÁN CHƯA GỬI LÊN SÀN CHỜ GIẢI TỎA (GIAO DỊCH 8810)', 'Y', 1, '1', 'P', 'OD8810', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW RELEASE SECURED SELL SENDING ORDER(WAIT FOR 8810)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;