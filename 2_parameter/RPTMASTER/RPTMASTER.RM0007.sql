SET DEFINE OFF;DELETE FROM RPTMASTER WHERE 1 = 1 AND NVL(RPTID,'NULL') = NVL('RM0007','NULL');Insert into RPTMASTER   (RPTID, DSN, MODCODE, FONTSIZE, RHEADER, PHEADER, RDETAIL, PFOOTER, RFOOTER, DESCRIPTION, AD_HOC, RORDER, PSIZE, ORIENTATION, STOREDNAME, VISIBLE, AREA, ISLOCAL, CMDTYPE, ISCAREBY, ISPUBLIC, ISAUTO, ORD, AORS, ROWPERPAGE, EN_DESCRIPTION, STYLECODE, TOPMARGIN, LEFTMARGIN, RIGHTMARGIN, BOTTOMMARGIN, SUBRPT, ISCMP, ISDEFAULTDB) Values   ('RM0007', 'HOST', 'RM', '12', '5', '5', '60', '5', '5', 'DANH SÁCH TIỂU KHOẢN TIỀN CÓ SỐ DƯ LỆCH VỚI SỐ  DƯ TÀI  KHOẢN GIAO DỊCH CHỨNG KHOÁN TẠI NGÂN HÀNG-COREBANK', 'Y', 1, '1', 'P', 'RM0007', 'N', 'B', 'N', 'V', 'N', 'N', 'M', '000', 'S', -1, 'VIEW ACCOUNT BALANCE DOES NOT MATCH WITH HOLDED AMOUNT', '', 0, 0, 0, 0, 'N', 'N', 'Y');COMMIT;