SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0040','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('OD0040', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'BÁO CÁO GIÁ TRỊ GIAO DỊCH THEO KHÁCH HÀNG THEO THỜI GIAN', 'Y', 1, '1', 'L', 'OD0040', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'BÁO CÁO GIAO DỊCH CHỨNG KHOÁN THEO SỐ TÀI KHOẢN KIÊM BẢNG KÊ HOA HỒNG MÔI GIỚI PHÁT SINH TRONG THÁNG', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;