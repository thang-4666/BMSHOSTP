SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0030','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CF0030', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'BẢNG KÊ THU THUẾ THU NHẬP CÁ NHÂN', 'Y', 1, '1', 'L', 'CF0030', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BẢNG KÊ THU THUẾ THU NHẬP CÁ NHÂN', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;