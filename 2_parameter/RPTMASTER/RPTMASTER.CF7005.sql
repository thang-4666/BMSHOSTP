SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CF7005','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CF7005', 'HOST', 'CF', '12', '5', '5', '60', '5', '5', 'THAY ĐỔI THÔNG TIN ĐỀ NGHỊ KẾT NỐI COREBANK', 'Y', 1, '1', 'P', 'CF7005', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'THAY ĐỔI THÔNG TIN ĐỀ NGHỊ KẾT NỐI COREBANK', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;