SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3324','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CA3324', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'ĐĂNG KÝ MUA CP PHÁT HÀNH THÊM KHÔNG CẮT TIỀN CI', 'Y', 1, '1', 'P', 'CA3324', 'Y', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'ĐĂNG KÝ MUA CP PHÁT HÀNH THÊM KHÔNG CẮT TIỀN CI', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;