SET DEFINE OFF;DELETE FROM VSDTXMAP WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('0035','NULL');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO) Values   ('T', '0035', '598.NEWM/AOPN', '', '$30', '@0', '<$TXDATE>', '');COMMIT;