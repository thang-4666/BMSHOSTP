SET DEFINE OFF;DELETE FROM APPTX WHERE 1 = 1 AND NVL(APPTYPE,'NULL') = NVL('AF','NULL');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('AF', '0081', 'U', 'U', 'CAREBY', 'C', '', '', '', '', 'AFMAST', 'AFTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('AF', '0090', 'U', 'U', 'STATUS', 'C', '', '', '', '', 'SEDEPOSIT', 'AFTRAN', '');COMMIT;