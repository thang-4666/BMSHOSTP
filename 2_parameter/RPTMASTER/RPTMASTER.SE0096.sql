SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE0096','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE0096', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'BÁO CÁO CHI TIẾT PHÍ HOA HỒNG DUY TRÌ TÀI KHOẢN GIAO DỊCH QUỸ MỞ', 'Y', 1, '1', 'L', 'SE0096', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'THÔNG BÁO TIỀN LÃI ĐƯỢC NHẬN CỦA CÁC TRÁI CHỦ', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;