SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('505.NEWM.LINK//542','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('505.NEWM.LINK//542', 'Chi tiết giải tỏa chứng khoán một phần', '505', 'Y', 'INF', '', '', '', '', 'Y', '', '', 'DR');COMMIT;