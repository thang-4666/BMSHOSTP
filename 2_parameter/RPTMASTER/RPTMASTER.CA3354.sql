SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CA3354','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CA3354', 'HOST', 'CA', '12', '5', '5', '60', '5', '5', 'DS CHỜ PHÂN BỔ TIỀN VÀO TK-THUẾ TẠI TCPH(GD 3354)', 'Y', 1, '1', 'P', 'CA3354', 'N', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW CORPORATE ACTIONS TO EXECUTE-IM (WAIT FOR 3354)', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;