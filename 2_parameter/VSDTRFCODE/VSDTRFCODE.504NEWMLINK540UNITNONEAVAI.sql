SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('504.NEWM.LINK//540.UNIT/NONE/AVAI','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('504.NEWM.LINK//540.UNIT/NONE/AVAI', 'Chi tiết cầm cố cổ phiếu thường tự do giao dịch', '504', 'Y', 'REQ', '2235', '', '', '', 'Y', '', '2236', 'DR');COMMIT;