SET DEFINE OFF;DELETE FROM VSDTXMAP WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('2235','NULL');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '540.NEWM.RVPO.UNIT/NONE/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '540.NEWM.RVPO.UNIT/PTA/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '540.NEWM.RVPO.FAMT/NONE/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '540.NEWM.RVPO.FAMT/PTA/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '504.NEWM.LINK//540.UNIT/NONE/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '504.NEWM.LINK//540.UNIT/PTA/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '504.NEWM.LINK//540.FAMT/NONE/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');Insert into VSDTXMAP   (OBJTYPE, OBJNAME, TRFCODE, FLDREFCODE, FLDNOTES, AMTEXP, AFFECTDATE, FLDACCTNO, FLDKEYSEND, VALUESEND) Values   ('T', '2235', '504.NEWM.LINK//540.FAMT/PTA/AVAI', '$04', '$30', '$10', '<$TXDATE>', '', '@Y', 'Y');COMMIT;