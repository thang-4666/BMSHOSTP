SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('MR3013','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('MR3013', 'HOST', 'MR', '12', '5', '5', '60', '5', '5', 'DANH SÁCH TIỂU KHOẢN BỊ XỬ LÝ BÁN', 'Y', 1, '1', 'L', 'MR3013', 'N', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'DANH SÁCH TÀI KHOẢN BỊ XỬ LÝ BÁN VÀO NGÀY GIAO DỊCH (DD/MM/YYYY)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;