SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('MR0007','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('MR0007', 'HOST', 'MR', '12', '5', '5', '60', '5', '5', 'PHIẾU TÍNH LÃI VAY MARGIN', 'Y', 1, '1', 'P', 'MR0007', 'Y', 'S', 'N', 'R', 'N', 'N', 'M', '000', 'S', -1, 'PHIẾU TÍNH LÃI VAY MARGIN', '', 0, 0, 0, 0, 'Y', 'N', 'Y');COMMIT;