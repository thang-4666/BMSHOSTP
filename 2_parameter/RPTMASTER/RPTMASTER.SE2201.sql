SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2201','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE2201', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'DANH SÁCH RÚT CHỨNG KHOÁN CHỜ XÁC NHẬN TỪ TTLK  (GIAO DỊCH 2201)', 'Y', 1, '1', 'P', 'SE2201', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW PENDING TO WITHDRAW (WAIT FOR 2201)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;