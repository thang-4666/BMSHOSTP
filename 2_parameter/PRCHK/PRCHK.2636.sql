SET DEFINE OFF;DELETE FROM PRCHK WHERE 1 = 1 AND NVL(TLTXCD,'NULL') = NVL('2636','NULL');Insert into PRCHK   (TLTXCD, CHKTYPE, TYPE, TYPEID, BRIDTYPE, PRTYPE, ACCFLDCD, TYPEFLDCD, DORC, AMTEXP, ODRNUM, UDPTYPE, DELTD, LNACCFLDCD, LNTYPEFLDCD) Values   ('2636', 'L', 'AFTYPE', '03', '0', 'P', '03', '', 'C', '12', 0, 'I', 'Y', '', '');COMMIT;