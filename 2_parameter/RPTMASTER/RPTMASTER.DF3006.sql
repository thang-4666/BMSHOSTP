SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('DF3006','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('DF3006', 'HOST', 'DF', '12', '5', '5', '60', '5', '5', 'THEO DÕI TRẠNG THÁI DEAL TỔNG BỊ CẢNH BÁO', 'Y', 1, '1', 'P', '', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW STATUS OF DF GROUP DEAL', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;