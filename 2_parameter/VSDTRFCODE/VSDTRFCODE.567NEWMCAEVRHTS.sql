SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('567.NEWM.CAEV//RHTS','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('567.NEWM.CAEV//RHTS', 'Từ chối đăng ký quyền mua', '567', 'Y', 'CFN', '3357', '', '', '3357', 'Y', 'Reject the right issue subscription');COMMIT;