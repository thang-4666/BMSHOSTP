SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('OD0083','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB, ICONFILENAME) Values   ('OD0083', 'HOST', 'OD', '12', '5', '5', '60', '5', '5', 'BẢNG KÊ CHUYỂN KHOẢN CK MUA CHỜ VỀ TỪ TK THƯỜNG SANG TK MARGIN', 'Y', 1, '1', 'P', 'OD0083', 'Y', 'S', 'N', 'R', 'Y', 'Y', 'M', '000', 'S', -1, 'BẢNG KÊ CHUYỂN KHOẢN CK MUA CHỜ VỀ TỪ TK THƯỜNG SANG TK MARGIN', '', 0, 0, 0, 0, 'N', 'N', 'Y', '');COMMIT;