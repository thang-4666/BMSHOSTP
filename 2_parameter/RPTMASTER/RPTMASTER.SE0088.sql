SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE0088','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE0088', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'GIẤY ĐỀ NGHỊ CHUYỂN KHOẢN CHỨNG KHOÁN (MẪU 26/LK)', 'Y', 1, '1', 'L', 'SE0088', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'GIẤY ĐỀ NGHỊ CHUYỂN KHOẢN CHỨNG KHOÁN (MẪU 26/LK)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;