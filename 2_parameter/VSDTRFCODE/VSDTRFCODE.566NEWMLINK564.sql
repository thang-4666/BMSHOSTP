SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('566.NEWM.LINK//564','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('566.NEWM.LINK//564', 'Thông báo kết quả CA cho TVLK và TCPH', '566', 'Y', 'INF', '', '', '', '', 'Y', '', '', 'DR');COMMIT;