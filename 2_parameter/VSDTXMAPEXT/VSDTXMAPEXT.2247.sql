SET DEFINE OFF;DELETE FROM VSDTXMAPEXT WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('2247','NULL');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', NULL, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/AVAI/SPCU', 'REDUCTIONVAL', 'N', '@0', '', 'Giá trị khấu hao', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'QTTY', 'N', '$06', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI', 'REDUCTIONVAL', 'N', '@0', '', 'Giá trị khấu hao', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/NONE/NAVAI/SPCU', 'REDUCTIONVAL', 'N', '@0', '', 'Giá trị khấu hao', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.FAMT/PTA/AVAI', 'REDUCTIONVAL', 'N', '@0', '', 'Giá trị khấu hao', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/AVAI/SPCU', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/NONE/NAVAI/SPCU', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'ISINCODE', 'C', '$01', 'SELECT ISINCODE FROM SBSECURITIES WHERE CODEID=''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'QTTY', 'N', '$10', '', 'Khối lượng', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'CUSTODYCD', 'C', '$13', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'REBICCODE', 'C', '$27', 'SELECT NVL(D.BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER D WHERE D.DEPOSITID = ''<$FILTERID>''', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'RECUSTODYCD', 'C', '$28', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '2247', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');COMMIT;