SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFLIMIT','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFLIMIT', 'Quản lý hạn mức chung', 'Common credit limit of the bank', 'SELECT MST.AUTOID, MST.BANKID, MST.LMAMT, MST.LMAMTMAX, CF.FULLNAME,
A.CDCONTENT STATUS, A0.CDCONTENT DESC_LMTYP, A1.CDCONTENT DESC_LMSUBTYPE,
A2.CDCONTENT DESC_LMCHKTYP,MST.ODAMT,
(case when mst.lmsubtype = ''TD'' then MST.lmamt-MST.ODAMT WHEN mst.lmsubtype = ''DFMR'' then MST.LMAMTMAX-MST.ODAMT-BDODAMT.odamt else MST.LMAMTMAX-MST.ODAMT end) AVLLIMIT, mst.ODR,
nvl(BDODAMT.odamt,0) BDODAMT,nvl(advdue.amt,0) dueamt,
(CASE WHEN MST.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW
FROM (select mst.*,nvl(cspks_cfproc.fn_get_bank_outstanding(mst.bankid,mst.lmsubtype),0) ODAMT from CFLIMIT MST) mst,
 CFMAST CF, ALLCODE A, ALLCODE A0, ALLCODE A1, ALLCODE A2,
 (select sum(amt) odamt,custbank,''ADV'' lmsubtype
  from advreslog ,(select * from sysvar where varname=''CURRDATE'') SYS
  where deltd <> ''Y'' and txdate <to_date(sys.varvalue,''DD/MM/RRRR'') group by custbank
  UNION ALL 
 SELECT NVL(SUM(PRINNML + PRINOVD),0) odamt, LN.CUSTBANK ,''DFMR'' LMSUBTYPE
  FROM LNMAST LN 
  WHERE  RRTYPE =''B''
  GROUP BY  CUSTBANK             
  ) BDODAMT,
  (select sum(log.amt) amt, log.custbank
   from (SELECT * FROM adschdhist UNION ALL
   SELECT * FROM  adschd) schd, 
   (SELECT * FROM advresloghist UNION ALL SELECT * FROM  advreslog) log,(select * from sysvar where varname=''CURRDATE'') SYS
   where schd.txnum=log.txnum and schd.txdate=log.txdate
   and schd.cleardt=to_date(sys.varvalue,''DD/MM/RRRR'')
   group by log.custbank) advdue
WHERE MST.BANKID=CF.CUSTID AND A.CDTYPE=''SY'' AND A.CDNAME=''APPRV_STS'' AND A.CDVAL=MST.STATUS
AND A0.CDTYPE=''CF'' AND A0.CDNAME=''LMTYP'' AND A0.CDVAL=MST.LMTYP
AND A1.CDTYPE=''CF'' AND A1.CDNAME=''LMSUBTYPE'' AND A1.CDVAL=MST.LMSUBTYPE
AND A2.CDTYPE=''CF'' AND A2.CDNAME=''LMCHKTYP'' AND A2.CDVAL=MST.LMCHKTYP
and mst.bankid= BDODAMT.custbank(+)
and mst.LMSUBTYPE= BDODAMT.LMSUBTYPE(+)
and mst.bankid=advdue.custbank(+) AND <$SEARCHKEY>', 'CFLIMIT', 'frmCFLIMIT', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;