SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2235','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE2235', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'Gửi hồ sơ cầm cố lên trung tâm(GIAO DỊCH 2235)', 'Y', 1, '1', 'P', 'SE2235', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW PENDING TO SEND MORTAGE CENTER (WAIT FOR 2235)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;