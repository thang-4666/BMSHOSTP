SET DEFINE OFF;DELETE FROM VSDTRFCODE WHERE 1 = 1 AND NVL(TRFCODE,'NULL') = NVL('548.INST..SETR//COLO.','NULL');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('548.INST..SETR//COLO.', 'Từ chối giải tỏa chứng khoán', '548', 'Y', 'CFN', '2257', '', '', '2256', 'Y', 'Reject requests of release blocking securities');Insert into VSDTRFCODE   (TRFCODE, DESCRIPTION, VSDMT, STATUS, TYPE, TLTXCD, SEARCHCODE, FILTERNAME, REQTLTXCD, AUTOCONF, EN_DESCRIPTION) Values   ('548.INST..SETR//COLO.', 'Từ chối phong tỏa chứng khoán', '548', 'Y', 'CFN', '2236', '', '', '2235', 'Y', 'Reject requests of blocking securities');COMMIT;