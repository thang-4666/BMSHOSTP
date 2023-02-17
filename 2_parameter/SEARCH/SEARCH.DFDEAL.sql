SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DFDEAL','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DFDEAL', 'Tiểu khoản DF', 'Deal information', 'select v.*,cd.cdcontent DEALTYPE_DESC,
  v.PRINNML+STSTERM.INTNMLACRTERM+v.INTDUE+STSTERM.FEEINTNMLACRTERM+v.FEEINTDUE+v.OPRINNML+v.OINTNMLACR+v.OINTDUE+v.FEE+v.FEEDUE -nvl(sts.NML,0) INDUEAMT,
  nvl(sts.NML,0) DUEAMT, v.PRINOVD+v.INTOVDACR+v.INTNMLOVD+v.FEEINTOVDACR+v.FEEINTNMLOVD+v.OPRINOVD+v.OINTOVDACR+v.OINTNMLOVD+v.FEEOVD OVERDUEAMT,
  mst.EXPDATE, (CASE WHEN TYP.NINTCD=''000'' THEN 1 ELSE 0 END) FLAGINTACR, -- N?U LÃ€ 000 LÃ€ CÃCH TÃNH NHU CU
  0 INTDAY,
  0 INTOVDDAY,
  STSTERM.INTNMLACRTERM+STSTERM.FEEINTNMLACRTERM+ v.OINTNMLACR + v.OINTOVDACR + v.INTOVDACR +V.FEEINTOVDACR INTACR, greatest(v.INTAMTACR+v.feeamt,v.FEEMIN-v.RLSFEEAMT) DEALFEEAMT,
  (CASE WHEN MST.INTPAIDMETHOD <> ''L'' THEN 1 ELSE 0 END ) ISPAYINTIM,
  (CASE WHEN MST.INTPAIDMETHOD =''P'' THEN 1 ELSE 0 END) ISFLOATINT,
    to_date(mst.RLSDATE+mst.minterm,''DD/MM/YYYY'') mindate,
   nvl( ststerm.INTNMLACRTERM,0) INTNMLACRTERM,    nvl(ststerm.FEEINTNMLACRTERM,0) FEEINTNMLACRTERM,
    a1.cdcontent intpaidmethoddis
    from v_getDealInfo v, allcode cd, securities_info sb,
   (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
          WHERE S.OVERDUEDATE = TO_DATE((select varvalue from sysvar where grname =''SYSTEM'' and varname =''CURRDATE''),''DD/MM/RRRR'') AND S.NML > 0 AND S.REFTYPE IN (''P'')
              AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN (''P'',''R'',''C'')
          GROUP BY S.ACCTNO, M.TRFACCTNO
          ORDER BY S.ACCTNO) sts, lnmast mst, lntype typ, (select TO_DATE(VARVALUE,''DD/MM/RRRR'') currdate from sysvar where varname=''CURRDATE'') dt,
    (SELECT S.ACCTNO, ROUND(SUM(GREATEST(
    (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.RATE1*M.MINTERM/100/360
    ELSE nml*S.RATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.RATE2/100/360*(to_date(S.RLSDATE+m.minterm,''DD/MM/YYYY'')-to_date(S.DUEDATE,''DD/MM/YYYY'')) END)
                      ,S.INTNMLACR)) ,4)INTNMLACRTERM,
           ROUND (SUM(GREATEST(
    (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.cfRATE1*M.MINTERM/100/360
    ELSE nml*S.CFRATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.CFRATE2/100/360*(to_date(S.RLSDATE+m.minterm,''DD/MM/YYYY'')-to_date(S.DUEDATE,''DD/MM/YYYY'')) END)
                      ,S.FEEINTNMLACR)),4) FEEINTNMLACRTERM,
             M.TRFACCTNO
           FROM LNSCHD S, LNMAST M
          WHERE    S.REFTYPE IN (''P'')  AND s.acctno=m.acctno
          GROUP BY S.ACCTNO, M.TRFACCTNO
          ORDER BY S.ACCTNO) ststerm,
          ALLCODE A1
  where v.status=''A'' and v.lnacctno = sts.acctno (+) and v.codeid=sb.codeid AND V.GROUPID IS NULL
  and v.afacctno like nvl(''<$AFACCTNO>'',''%'') and mst.actype=typ.actype and v.lnacctno=mst.acctno
  and cd.cdname=''DFTYPE'' and cd.cdtype=''DF'' and cd.cdval=v.dftype
   AND  v.lnacctno = ststerm.acctno (+) and v.afacctno=ststerm.TRFACCTNO(+)
   and A1.cdtype=''LN'' and A1.cdname=''INTPAIDMETHOD'' and A1.cdval=mst.INTPAIDMETHOD
  ', 'DFMAST', 'frmCreateDFDeal', '', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;