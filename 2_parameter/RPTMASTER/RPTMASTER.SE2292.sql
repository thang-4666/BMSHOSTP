SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2292','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('SE2292', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'GHI NHẬN HỒ SƠ RÚT CHỨNG KHOÁN ĐÃ ĐƯỢC GỬI LÊN TRUNG TÂM (GIAO DỊCH 2292)', 'Y', 1, '1', 'P', 'SE2205', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'RECORD 2200 (WAIT FOR 2292)', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;