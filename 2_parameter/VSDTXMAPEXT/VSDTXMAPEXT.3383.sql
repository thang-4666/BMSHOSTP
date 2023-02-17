SET DEFINE OFF;DELETE FROM VSDTXMAPEXT WHERE 1 = 1 AND NVL(OBJNAME,'NULL') = NVL('3383','NULL');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'QTTY', 'N', '$21', '', 'Khối lượng', '', '', '', NULL, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'ISINCODE', 'C', '$01', 'SELECT SB.ISINCODE FROM sbsecurities sb, sbsecurities sb1 WHERE NVL(sb1.refcodeid,sb1.codeid)= sb.codeid AND sb1.codeid =''<$FILTERID>''', 'Mã chứng khoán', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'CUSTODYCD', 'C', '$36', '', 'Tài khoản nhà đầu tư', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'TXDATE', 'D', '<$BUSDATE>', '', 'Ngày tạo yêu cầu', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'RECUSTODYCD', 'C', '$07', '', 'Tài khoản nhà đầu tư bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'REBICCODE', 'C', '$08', 'SELECT NVL(BICCODE, ''XXAAXXAA'') FROM DEPOSIT_MEMBER WHERE DEPOSITID = SUBSTR(''<$FILTERID>'',1,3)', 'BICCODE bên nhận', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'BUYRDAAS', 'C', '$07', 'SELECT CASE WHEN substr(CF.CUSTODYCD,4,1)=''P'' THEN ''CSD''
            WHEN country = ''234'' THEN VSD.BICCODE ||''-CUSD''
            WHEN country <> ''234'' THEN VSD.BICCODE ||''-CUSF''
            ELSE '''' END
FROM CFMAST CF,VSDBICCODE VSD
WHERE VSD.TRFTYPE =''DR''
AND CF.CUSTODYCD=''<$FILTERID>''', 'Loại khách hàng bên gửi', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'BUYRPCOD', 'C', '$07', 'SELECT Pcod FROM cfmast WHERE custodycd=''<$FILTERID>''', 'PCOD nhà đầu tư bên chuyển', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'PARVALUE', 'N', '$12', '', 'Mệnh giá', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'SELLDAAS', 'C', '$36', 'SELECT CASE WHEN substr(CF.CUSTODYCD,4,1)=''P'' THEN ''CSD''
            WHEN country = ''234'' THEN VSD.BICCODE ||''-CUSD''
            WHEN country <> ''234'' THEN VSD.BICCODE ||''-CUSF''
            ELSE '''' END
FROM CFMAST CF,VSDBICCODE VSD
WHERE VSD.TRFTYPE =''DR''
AND CF.CUSTODYCD=''<$FILTERID>''', 'Loại khách hàng bên gửi', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'SELLPCOD', 'C', '$36', 'SELECT Pcod FROM cfmast WHERE custodycd=''<$FILTERID>''', 'PCOD nhà đầu tư bên chuyển', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'TRFTXNUM', 'C', '$00', '', 'Số tham chiếu chuyển khoản', '', '', '', 1233219999, '', '');Insert into VSDTXMAPEXT   (OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL, CAPTION, CHSTATUS, EN_CAPTION, SPLIT, ODRNUM, CONVERT, MAXLENGTH) Values   ('T', '3383', '542.NEWM.TRAD.UNIT/PTA/AVAI', 'AMT', 'N', '12**21', '', 'Giá trị', '', '', '', 1233219999, '', '');COMMIT;