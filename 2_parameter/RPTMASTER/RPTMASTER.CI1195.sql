SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('CI1195','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('CI1195', 'HOST', 'CI', '12', '5', '5', '60', '5', '5', 'DANH SÁCH GIAO DỊCH ĐỒNG BỘ TỪ NGÂN HÀNG (GIAO DỊCH 1195)', 'Y', 1, '1', 'P', 'CI1195', 'N', 'A', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'IMPORT CASH CREDIT', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;