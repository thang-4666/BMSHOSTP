SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('598.NEWM/RSID/INCR','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION, REJTLTXCD, TRFTYPE) Values   ('598.NEWM/RSID/INCR', 'Yêu cầu đăng ký thông tin khách hàng nước ngoài - tổ chức', '598', 'Y', 'REQ', '0136', '', '', '', 'Y', '', 'CFREJ', 'DR');COMMIT;