SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RM0004','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('RM0004', 'HOST', 'RM', '12', '5', '5', '60', '5', '5', 'SINH BẢNG KÊ CHUYỂN TIỀN SANG TÀI KHOẢN PHỤ', 'Y', 1, '1', 'P', 'RM0004', 'N', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'SINH BẢNG KÊ CHUYỂN TIỀN SANG TÀI KHOẢN PHỤ (6649)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;