SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI0090','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI0090', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'BẢNG KÊ PHÁT SINH GIAO DỊCH MUA BÁN QUYỀN NHẬN TIỀN BÁN CHỨNG KHOÁN', 'Y', 1, '1', 'L', 'CI0090', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'BẢNG KÊ PHÁT SINH GIAO DỊCH MUA BÁN QUYỀN NHẬN TIỀN BÁN CHỨNG KHOÁN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;