SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('REDHT003','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('REDHT003', 'HOST', 'RE', '12', '5', '5', '60', '5', '5', 'PHỤ LỤC 02: TỔNG HỢP PHÍ CÁN BỘ BIDV ĐƯỢC HƯỞNG THÁNG', 'Y', 1, '1', 'L', 'REDHT003', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'PHỤ LỤC 02: TỔNG HỢP PHÍ CÁN BỘ BIDV ĐƯỢC HƯỞNG THÁNG', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;