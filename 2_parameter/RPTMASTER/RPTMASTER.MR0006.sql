SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('MR0006','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('MR0006', 'HOST', 'MR', '12', '5', '5', '60', '5', '5', 'THÔNG BÁO ĐẾN HẠN KÈM THÔNG BÁO GỌI KÝ QUỸ', 'Y', 1, '1', 'L', 'MR0006', 'Y', 'S', 'N', 'R', 'N', 'Y', 'M', '000', 'S', -1, 'THÔNG BÁO ĐẾN HẠN XÁC NHẬN KÝ QUỸ KÈM THÔNG BÁO GỌI KÝ QUỸ', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;