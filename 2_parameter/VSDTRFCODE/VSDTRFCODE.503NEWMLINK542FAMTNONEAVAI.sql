SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('503.NEWM.LINK//542.FAMT/NONE/AVAI','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('503.NEWM.LINK//542.FAMT/NONE/AVAI', 'Chi tiết giải tỏa cầm cố trái phiếu thường tự do giao dịch', '503', 'Y', 'REQ', '2256', '', '', '', 'Y', '', '2257', 'DR');COMMIT;