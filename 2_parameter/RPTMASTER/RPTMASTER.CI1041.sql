SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI1041','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI1041', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'BÁO CÁO DANH SÁCH KHÁCH HÀNG THU PHÍ LƯU KÝ 02 LẦN', 'Y', 1, '1', 'L', 'CI1041#CI1042', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO DANH SÁCH KH THU PHÍ LƯU KÝ 02 LẦN', '', 0, 0, 0, 0, 'Y', 'N', 'Y');COMMIT;