SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('SE2234','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('SE2234', 'HOST', 'SE', '12', '5', '5', '60', '5', '5', 'Hủy yêu cầu cầm cố chưa gửi VSD(GIAO DỊCH 2234)', 'Y', 1, '1', 'P', 'SE2234', 'Y', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW PENDING TO CANCEL SEND MORTAGE CENTER (WAIT FOR 2234)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;