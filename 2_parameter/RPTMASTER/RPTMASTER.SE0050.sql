SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE0050','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE0050', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO LIỆT KÊ CÁC QUY TRÌNH CHỨNG KHOÁN CHƯA HOÀN TẤT', 'Y', 1, '1', 'L', 'SE0050', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO LIỆT KÊ CÁC QUY TRÌNH CHỨNG KHOÁN CHƯA HOÀN TẤT', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;