SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3328','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('CA3328', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'HỦY ĐĂNG KÝ NHẬN CỔ PHIẾU CHUYỂN ĐỔI TỪ TRÁI PHIẾU', 'Y', 1, '1', 'P', 'CA3328', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'HỦY ĐĂNG KÝ NHẬN CỔ PHIẾU CHUYỂN ĐỔI TỪ TRÁI PHIẾU', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;