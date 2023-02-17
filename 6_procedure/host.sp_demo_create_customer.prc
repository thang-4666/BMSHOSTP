SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_DEMO_CREATE_CUSTOMER" (v_fromidx IN NUMBER, v_toidx IN NUMBER, v_txdate IN VARCHAR2,
  v_brid IN VARCHAR2, v_carebyid IN VARCHAR2, v_aftype IN VARCHAR2, v_symbols IN VARCHAR2, v_amt NUMBER, v_qtty NUMBER)
IS
 v_CURRIDX       NUMBER(10);
 v_RUNNINGFM      VARCHAR2(10);
 v_CUSTID       VARCHAR2(20);
 v_COMPANYCD      VARCHAR2(5);
 v_CUSTODYCD      VARCHAR2(20);
 v_AFACCTNO       VARCHAR2(20);
 v_CIACTYPE       VARCHAR2(20);
 v_SEACTYPE       VARCHAR2(20);
BEGIN
  v_RUNNINGFM := '000000';
  v_CURRIDX := 0;
  --?Y TH?G TIN V?O B?NG T?M
  DELETE FROM SYS_FLEX_TMPCMDSQL;
  FOR v_CURRIDX IN v_fromidx..v_toidx LOOP
  --06 s? cu?i c?a m?h? h?
  v_CUSTID := SUBSTR(v_RUNNINGFM || TO_CHAR(v_CURRIDX),LENGTH(v_RUNNINGFM || TO_CHAR(v_CURRIDX))-LENGTH(v_RUNNINGFM)+1);
  INSERT INTO SYS_FLEX_TMPCMDSQL VALUES (v_CUSTID);
  END LOOP;

  --Prefix s? luu k? c?a kh? h? l?h? h? trong nu?c
  SELECT VARVALUE || 'C' INTO v_COMPANYCD FROM SYSVAR WHERE VARNAME='COMPANYCD';
  --Lo?i h?
  SELECT CITYPE, SETYPE INTO v_CIACTYPE, v_SEACTYPE FROM AFTYPE WHERE ACTYPE=v_aftype;
  --CFMAST
  insert into CFMAST (CUSTID, SHORTNAME, FULLNAME, MNEMONIC, DATEOFBIRTH, IDTYPE, IDCODE, IDDATE, IDPLACE, IDEXPIRED,
    ADDRESS, PHONE, MOBILE, FAX, EMAIL, COUNTRY, PROVINCE, POSTCODE, RESIDENT, CLASS, GRINVESTOR, INVESTRANGE, TIMETOJOIN, CUSTODYCD,
    STAFF, COMPANYID, POSITION, SEX, SECTOR, BUSINESSTYPE, INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, FOCUSTYPE, BRID, CAREBY, APPROVEID, LASTDATE, AUDITORID, AUDITDATE, BANKACCTNO, BANKCODE, VALUDADDED, ISSUERID, DESCRIPTION, MARRIED, REFNAME, TAXCODE, INTERNATION, OCCUPATION, EDUCATION, CUSTTYPE, STATUS, PSTATUS, INVESTMENTEXPERIENCE, PCUSTODYCD, EXPERIENCECD, ORGINF, TLID, ISBANKING, PIN, USERNAME, MRLOANLIMIT, RISKLEVEL, TRADINGCODE, TRADINGCODEDT, LAST_CHANGE, OPNDATE)
  select v_brid || CMDSQL, v_brid || CMDSQL, 'Auto generate (' || v_brid || CMDSQL || ')', v_brid || CMDSQL, to_date('28-02-1970', 'dd-mm-yyyy'), '001', v_brid || CMDSQL, to_date('28-02-2000', 'dd-mm-yyyy'), 'HANOI', to_date('28-02-2015', 'dd-mm-yyyy'),
    '11th floor, 434 Tran Khat Chan, Hai Ba Trung dist., Hanoi, Vietnam', '', '', '', '', '234', '--', '', '', '001', '001', '001', '001', v_COMPANYCD || CMDSQL,
    '005', '', '001', '001', '001', '009', '001', '001', '001', '001', '001', v_brid, v_carebyid, '', null, '', null,  '', '000', '', '', '', '001', '', '', v_COMPANYCD || CMDSQL, '001', '002', 'I  ', 'A', 'PPP', '', '', '00000', '', '', 'N', '', '', 0.0000, 'M', '', to_date('28-02-2010', 'dd-mm-yyyy'), '', to_date('28-02-2011', 'dd-mm-yyyy')
  from SYS_FLEX_TMPCMDSQL;

    --AFMAST
    insert into AFMAST (ACTYPE, CUSTID, ACCTNO, AFTYPE,  BANKACCTNO, BANKNAME, SWIFTCODE, LASTDATE, STATUS, PSTATUS,  ADVANCELINE, BRATIO, TERMOFUSE, DESCRIPTION,  ISOTC,  PISOTC, OPNDATE, COREBANK, VIA, MRIRATE, MRMRATE, MRLRATE,  MRCRLIMIT, MRCRLIMITMAX, GROUPLEADER, T0AMT, BRID, LAST_CHANGE, CLSDATE, CAREBY, AUTOADV, TLID)
    select v_aftype, v_brid || CMDSQL, v_brid || CMDSQL, '001', '', '000', '', to_date('28-02-2011', 'dd-mm-yyyy'), 'A', 'PP', 0, 0, '001', '', 'N', 'N', to_date('28-02-2011', 'dd-mm-yyyy'), 'N', 'F',  100.0000, 90.0000, 80.0000, 0.0000, 0.0000, '', 0.0000, v_brid, '24-MAR-11 09.13.02.928000 AM', null, v_carebyid, 'N', ''
  from SYS_FLEX_TMPCMDSQL;
    --CIMAST
    insert into CIMAST (ACTYPE, ACCTNO, CCYCD, AFACCTNO, CUSTID, OPNDATE, CLSDATE, LASTDATE, DORMDATE, STATUS, PSTATUS, BALANCE, CRAMT, DRAMT, CRINTACR, CRINTDT, ODINTACR, ODINTDT, AVRBAL, MDEBIT, MCREDIT, AAMT, RAMT, BAMT, EMKAMT, MMARGINBAL, MARGINBAL, ICCFCD, ICCFTIED, ODLIMIT, ADINTACR, ADINTDT, FACRTRADE, FACRDEPOSITORY, FACRMISC, MINBAL, ODAMT, NAMT, FLOATAMT, HOLDBALANCE, PENDINGHOLD, PENDINGUNHOLD, COREBANK, RECEIVING, NETTING, MBLOCK, OVAMT, DUEAMT, T0ODAMT, MBALANCE, MCRINTDT, TRFAMT, LAST_CHANGE, DFODAMT, DFDEBTAMT, DFINTDEBTAMT, CIDEPOFEEACR)
    select v_CIACTYPE, v_brid || CMDSQL, '00', v_brid || CMDSQL, v_brid || CMDSQL, to_date(v_txdate, 'dd-mm-yyyy'), null, to_date(v_txdate, 'dd-mm-yyyy'), null, 'A', '', v_amt, v_amt, 0.0000, 0.0000, to_date(v_txdate, 'dd-mm-yyyy'), 0.0000, to_date(v_txdate, 'dd-mm-yyyy'), 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, '', 'Y', 0.0000, 0, null, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 'N', 0.0000, 0.0000, 0, 0.0000, 0.0000, 0.0000, 0.0000, to_date(v_txdate, 'dd-mm-yyyy'), 0.0000, '24-MAR-11 09.38.31.750000 AM', 0.0000, 0.00, 0.0000, 0.0000
    from SYS_FLEX_TMPCMDSQL;
  --SEMAST
    insert into semast (ACTYPE, ACCTNO, CODEID, AFACCTNO, OPNDATE, CLSDATE, LASTDATE, STATUS, PSTATUS, IRTIED, IRCD, COSTPRICE, TRADE, MORTAGE, MARGIN, NETTING, STANDING, WITHDRAW, DEPOSIT, LOAN, BLOCKED, RECEIVING, TRANSFER, PREVQTTY, DCRQTTY, DCRAMT, DEPOFEEACR, REPO, PENDING, TBALDEPO, CUSTID, COSTDT, SECURED, ICCFCD, ICCFTIED, TBALDT, SENDDEPOSIT, SENDPENDING, DDROUTQTTY, DDROUTAMT, DTOCLOSE, SDTOCLOSE, QTTY_TRANSFER, LAST_CHANGE, DEALINTPAID, WTRADE)
    select v_SEACTYPE, v_brid || CMDSQL || CODEID, CODEID, v_brid || CMDSQL, to_date(v_txdate, 'dd-mm-yyyy'), null, to_date(v_txdate, 'dd-mm-yyyy'), 'A', '', 'Y', '001', 0.00, v_qtty, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_qtty, v_qtty*PARVALUE, 0, 0, 0, 0, v_brid || CMDSQL, null, 0, '', 'Y', null, 0, 0, 0, 0, 0, 0, 0, '24-MAR-11 11.00.19.050000 AM',  0.0000, 0
    from sbsecurities, SYS_FLEX_TMPCMDSQL where instr(v_symbols, SYMBOL || ',')>0;

  --S? d?ng WSNAME='AUTOGEN' d? l?c
  --TLLOGALL 1140
  insert into TLLOGALL (AUTOID, TXNUM, TXDATE, TXTIME, BRID, TLID, OFFID, OVRRQS, CHID, CHKID, TLTXCD, IBT, BRID2, TLID2, CCYUSAGE, OFF_LINE, DELTD, BRDATE, BUSDATE, TXDESC, IPADDRESS, WSNAME, TXSTATUS, MSGSTS, OVRSTS, BATCHNAME, MSGAMT, MSGACCT, CHKTIME, OFFTIME, CAREBYGRP)
  select seq_TLLOG.nextval, v_brid || LPAD(SEQ_AUTO_CREATE_CUSTOMER_TXNUM.nextval,6,'6'),
    to_date(v_txdate, 'dd-mm-yyyy'), '11:48:05', '0001', '0001', '0001', '@00', '0001', '', '1140', '', '', '', '00', 'N', 'N', to_date(v_txdate, 'dd-mm-yyyy'), to_date(v_txdate, 'dd-mm-yyyy'), 'Cash deposit', 'localhost', 'AUTOGEN', '1', '0', '0', 'DAY                 ', v_amt, v_brid || CMDSQL, '', '11:48:29', ''
  from SYS_FLEX_TMPCMDSQL;
  --TLLOGFLDALL 1140
  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '03', 0, v_brid || mst.CMDSQL, ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '88', 0, v_COMPANYCD || CMDSQL, ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '30', 0, 'Cash deposit', ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '10', v_amt, '', ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;
  --CITRANA
  insert into CITRANA (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, ACCTREF, AUTOID, TLTXCD, BKDATE, TRDESC)
  select dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), v_brid || mst.CMDSQL, '0012', v_amt, '', '', 'N', '', seq_citran.nextval, '1140', to_date(v_txdate, 'dd-mm-yyyy'), ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;

  insert into CITRANA (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, ACCTREF, AUTOID, TLTXCD, BKDATE, TRDESC)
  select dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), v_brid || mst.CMDSQL, '0014', v_amt, '', '', 'N', '', seq_citran.nextval, '1140', to_date(v_txdate, 'dd-mm-yyyy'), ''
  from SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='1140' AND dtl.MSGACCT=v_brid || mst.CMDSQL;

  --TLLOGALL 2245
  insert into TLLOGALL (AUTOID, TXNUM, TXDATE, TXTIME, BRID, TLID, OFFID, OVRRQS, CHID, CHKID, TLTXCD, IBT, BRID2, TLID2, CCYUSAGE, OFF_LINE, DELTD, BRDATE, BUSDATE, TXDESC, IPADDRESS, WSNAME, TXSTATUS, MSGSTS, OVRSTS, BATCHNAME, MSGAMT, MSGACCT, CHKTIME, OFFTIME, CAREBYGRP)
  select seq_TLLOG.nextval, v_brid || LPAD(SEQ_AUTO_CREATE_CUSTOMER_TXNUM.nextval,6,'6'),
    to_date(v_txdate, 'dd-mm-yyyy'), '11:49:03', '0001', '0001', '0001', '@00', '', '', '2245', '', '', '', '00', 'N', 'N', to_date(v_txdate, 'dd-mm-yyyy'), to_date(v_txdate, 'dd-mm-yyyy'), 'Inward SE Transfer', 'localhost', 'AUTOGEN', '1', '0', '0', 'DAY                 ', v_qtty, v_brid || CMDSQL || CODEID, '', '11:49:09', ''
  from sbsecurities, SYS_FLEX_TMPCMDSQL where instr(v_symbols, SYMBOL || ',')>0;

  --TLLOGFLDALL 2245
  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '11', v_qtty, '', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '31', 0, '', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '10', v_qtty, '', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '09', sb.parvalue, '', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '05', 0, v_brid || mst.CMDSQL || sb.codeid, ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '04', 0, v_brid || mst.CMDSQL, ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '88', 0, v_COMPANYCD || mst.CMDSQL, ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '30', 0, 'Inward SE Transfer', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '01', 0, sb.codeid, ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into TLLOGFLDALL (AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
  select seq_TLLOGFLD.nextval, dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), '03', 0, '001', ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  --SETRANA
  insert into SETRANA (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, AUTOID, ACCTREF, TLTXCD, BKDATE, TRDESC)
  select dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), v_brid || mst.CMDSQL || sb.codeid, '0051', v_qtty*sb.parvalue, '', '001', 'N', seq_setran.nextval, '', '2245', to_date(v_txdate, 'dd-mm-yyyy'), ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into SETRANA (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, AUTOID, ACCTREF, TLTXCD, BKDATE, TRDESC)
  select dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), v_brid || mst.CMDSQL || sb.codeid, '0052', v_qtty, '', '001', 'N', seq_setran.nextval, '', '2245', to_date(v_txdate, 'dd-mm-yyyy'), ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;

  insert into SETRANA (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, AUTOID, ACCTREF, TLTXCD, BKDATE, TRDESC)
  select dtl.txnum, to_date(v_txdate, 'dd-mm-yyyy'), v_brid || mst.CMDSQL || sb.codeid, '0012', v_qtty, '', '001', 'N', seq_setran.nextval, '', '2245', to_date(v_txdate, 'dd-mm-yyyy'), ''
  from sbsecurities sb, SYS_FLEX_TMPCMDSQL mst, TLLOGALL dtl where dtl.WSNAME='AUTOGEN' and dtl.TLTXCD='2245' AND dtl.MSGACCT=v_brid || mst.CMDSQL || sb.codeid and instr(v_symbols, sb.SYMBOL || ',')>0;
--  commit;
END;

 
 
 
 
/
