SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('540.NEWM.REAL.UNIT/PTA/NAVL','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('540.NEWM.REAL.UNIT/PTA/NAVL', 'Lưu ký cổ phiếu HCCN chờ giao dịch', '540', 'Y', 'REQ', '2241', '', '', '', 'Y', '', '2231', 'DR');COMMIT;