SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RM6683','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('RM6683', 'HOST', 'RM', '12', '5', '5', '60', '5', '5', 'TRA CỨU YÊN CẦU THU PHÍ LK CHỜ XỬ LÝ (6683)', 'Y', 1, '1', 'P', 'RM6681', 'N', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW PENDING COLLECT DEPOSITORY FEE TO PROCESS  (6683)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;