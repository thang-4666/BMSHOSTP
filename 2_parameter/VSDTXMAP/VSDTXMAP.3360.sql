SET DEFINE OFF;DELETE FROM VSDTXMAP WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('3360','NULL');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('I', '3360', '565.NEWM.CAEV//EXWA', '', '$30', '@0', '<$TXDATE>', '', '', '');COMMIT;