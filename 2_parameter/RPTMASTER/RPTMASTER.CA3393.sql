SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3393','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CA3393', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'HUỶ ĐĂNG KÝ MUA CP PHÁT HÀNH THÊM (KHÔNG PHONG TỎA TIỀN)', 'Y', 1, '1', 'P', 'CA3393', 'N', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'ĐĂNG KÝ MUA CP PHÁT HÀNH THÊM (KHÔNG PHONG TỎA TIỀN)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;