SET DEFINE OFF;DELETE FROM APPTX WHERE 1 = 1 AND NVL(APPTYPE,'NULL') = NVL('OD','NULL');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0001', 'U', 'U', 'ORSTATUS', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0002', 'C', 'C', 'EXPRICE', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0003', 'C', 'C', 'EXQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0010', 'U', 'U', 'CUSTID', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0011', 'U', 'D', 'REMAINQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0012', 'C', 'C', 'REMAINQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0013', 'C', 'C', 'EXECQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0014', 'C', 'C', 'CANCELQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0015', 'D', 'D', 'ADJUSTQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0016', 'C', 'C', 'ADJUSTQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0017', 'C', 'C', 'AAMT', 'N', '', '', '', '', 'STSCHD', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0018', 'C', 'C', 'FAMT', 'N', '', '', '', '', 'STSCHD', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0021', 'D', 'D', 'EXAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0022', 'C', 'C', 'EXAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0023', 'D', 'D', 'FEEAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0024', 'C', 'C', 'FEEAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0025', 'D', 'D', 'FEEACR', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0026', 'C', 'C', 'FEEACR', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0027', 'D', 'D', 'EXECAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0028', 'C', 'C', 'EXECAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0029', 'D', 'D', 'RLSSECURED', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0030', 'C', 'C', 'RLSSECURED', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0031', 'D', 'D', 'SECUREDAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0032', 'C', 'C', 'SECUREDAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0033', 'D', 'D', 'MATCHAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0034', 'C', 'C', 'MATCHAMT', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0035', 'D', 'D', 'EXPRICE', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0036', 'D', 'D', 'EXQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0037', 'D', 'D', 'CANCELQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0038', 'D', 'D', 'REJECTQTTY', 'N', '', '', '', '', 'ODMAST', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0039', 'U', 'U', 'VOUCHER', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0040', 'U', 'U', 'OODSTATUS', 'C', '', '', '', '', 'OOD', '', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0041', 'U', 'U', 'STSSTATUS', 'C', '', '', '', '', 'ODMAST', '', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0042', 'D', 'D', 'TRFEXEAMT', 'N', '', '', '', '', 'STSCHD', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0043', 'C', 'C', 'TRFEXEAMT', 'N', '', '', '', '', 'STSCHD', 'ODTRAN', '4');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0045', 'C', 'C', 'PRINPAID', 'N', '', '', '', '', 'VOUCHERODFEE', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0046', 'D', 'D', 'PRINPAID', 'N', '', '', '', '', 'VOUCHERODFEE', 'ODTRAN', '0');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0050', 'U', 'U', 'ERROD', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0051', 'U', 'U', 'ERRSTS', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0052', 'U', 'U', 'ERRREASON', 'C', '', '', '', '', 'ODMAST', 'ODTRAN', '');Insert into APPTX   (APPTYPE, TXCD, TXUPDATE, TXTYPE, FIELD, FLDTYPE, OFILE, OFILEACT, IFILE, INTF, TBLNAME, TRANF, FLDRND) Values   ('OD', '0053', 'U', 'U', 'CANCELSTATUS', 'C', '', '', '', '', 'ODMAST', '', '');COMMIT;