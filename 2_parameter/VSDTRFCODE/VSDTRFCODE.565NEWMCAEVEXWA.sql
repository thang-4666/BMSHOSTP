SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('565.NEWM.CAEV//EXWA','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('565.NEWM.CAEV//EXWA', 'Đăng kí chi trả lợi tức chứng quyền', '565', 'Y', 'REQ', '3360', '', '', '', 'Y', '', '3360', 'DR');COMMIT;