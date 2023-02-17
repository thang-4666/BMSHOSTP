SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DFDEALGR','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DFDEALGR', 'Tiểu khoản DF', 'Deal information', 'select v.*,
  v.PRINNML+v.INTNMLACR+v.INTDUE+v.OPRINNML+v.OINTNMLACR+v.OINTDUE+v.FEE+v.FEEDUE -nvl(sts.NML,0) INDUEAMT,
  nvl(sts.NML,0) DUEAMT, v.PRINOVD+v.INTOVDACR+v.INTNMLOVD+v.OPRINOVD+v.OINTOVDACR+v.OINTNMLOVD+v.FEEOVD OVERDUEAMT,
  mst.EXPDATE, (CASE WHEN TYP.NINTCD=''000'' THEN 1 ELSE 0 END) FLAGINTACR,
  0 INTDAY,
  0 INTOVDDAY,  mst.PRINPAID + mst.OPRINPAID-dfgroup.rlsamt RLSAMTDF,
  v.INTNMLACR+ v.OINTNMLACR + v.OINTOVDACR + v.INTOVDACR INTACR, greatest(v.INTAMTACR+v.feeamt,v.FEEMIN-v.RLSFEEAMT) DEALFEEAMT
  from v_getDealInfo v, allcode cd, securities_info sb,
   (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
          WHERE S.OVERDUEDATE = TO_DATE((select varvalue from sysvar where grname =''SYSTEM'' and varname =''CURRDATE''),''DD/MM/RRRR'') AND S.NML > 0 AND S.REFTYPE IN (''P'')
              AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN (''P'',''R'',''C'')
          GROUP BY S.ACCTNO, M.TRFACCTNO
          ORDER BY S.ACCTNO) sts,DFGROUP  ,lnmast mst, lntype typ, (select TO_DATE(VARVALUE,''DD/MM/RRRR'') currdate from sysvar where varname=''CURRDATE'') dt
  where v.status=''A'' and v.lnacctno = sts.acctno (+) and v.codeid=sb.codeid AND DFGROUP.GROUPID =V.GROUPID
  and v.afacctno like nvl(''<$AFACCTNO>'',''%'') and mst.actype=typ.actype and v.lnacctno=mst.acctno
  and cd.cdname=''DFTYPE'' and cd.cdtype=''DF'' and cd.cdval=v.dftype  AND V.DFQTTY+V.BLOCKQTTY+V.RCVQTTY+V.CARCVQTTY>0
  ', 'DFMAST', 'frmCreateDFDeal', '', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;