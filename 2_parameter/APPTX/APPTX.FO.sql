SET DEFINE OFF;DELETE FROM APPTX WHERE 1 = 1 AND NVL(APPTYPE,'NULL') = NVL('FO','NULL');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0001', 'U', 'U', 'STATUS', 'C', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0002', 'U', 'U', 'QUOTEPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0003', 'U', 'U', 'TRIGGERPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0004', 'U', 'U', 'CONFIRMEDVIA', 'C', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0005', 'U', 'U', 'FEEDBACKMSG', 'C', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0006', 'U', 'U', 'PRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0011', 'U', 'D', 'QUOTEPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0012', 'U', 'C', 'QUOTEPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0013', 'U', 'D', 'TRIGGERPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0014', 'U', 'C', 'TRIGGERPRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0015', 'U', 'D', 'QUANTITY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0016', 'U', 'C', 'QUANTITY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0017', 'U', 'D', 'EXECQTTY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0018', 'U', 'C', 'EXECQTTY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0019', 'U', 'D', 'REMAINQTTY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0020', 'U', 'C', 'REMAINQTTY', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0021', 'U', 'D', 'EXECAMT', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0022', 'U', 'C', 'EXECAMT', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0023', 'U', 'D', 'PRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('FO', '0024', 'U', 'C', 'PRICE', 'N', ' ', ' ', ' ', ' ', 'FOMAST', 'FOTRAN', '4');COMMIT;