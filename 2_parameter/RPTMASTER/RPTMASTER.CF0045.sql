SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF0045','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('CF0045', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'GIẤY ĐỀ NGHỊ XÁC NHẬN TÀI KHOẢN LƯU KÝ VÀ UỶ QUYỀN', 'Y', 1, '1', 'P', 'CF0045', 'N', 'S', 'N', 'R', 'Y', 'Y', 'M', '000', 'S', -1, 'GIẤY ĐỀ NGHỊ XÁC NHẬN TÀI KHOẢN LƯU KÝ VÀ UỶ QUYỀN', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;