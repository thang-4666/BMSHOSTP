SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF5009','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF5009', 'View theo dõi trạng thái Deal cầm cố VSD', 'DF mortage VSD status', 'select DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,
    DECODE(DF.LIMITCHK,''N'',0,1) LIMITCHECK ,
    DF.ORGAMT AMT, NVL(LNS.NML,0) + NVL(LNS.OVD,0) LNAMT, NVL(LNS.PAID,0) PAIDAMT , DF.LNACCTNO , A5.cdcontent DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
    DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION,
    (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '''' end )
    RRID , decode (df.RRTYPE,''O'',1,0) CIDRAWNDOWN,decode (df.RRTYPE,''B'',1,0) BANKDRAWNDOWN,
    decode (df.RRTYPE,''C'',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,
    A4.CDCONTENT RRTYPENAME, CF.MOBILESMS, CF.EMAIL, ci.mblock DFBLOCKAMT, dfamt, A6.cdcontent DEALVSDSTATUS,
    lns.nml, lns.ovd, LNS.INTNMLACR, lns.INTDUE, lns.intovd, lns.intovdprin, LNS.FEEINTNMLACR, lns.FEEINTDUE, lns.FEEintnmlovd, lns.FEEintovdacr,
    nvl(dfmast.SENDVSDQTTY,0), df.isvsd
from dftype, afmast af , cfmast cf, cimast ci, allcode A4, allcode A5, allcode A6,
    (select groupid, sum(SENDVSDQTTY) SENDVSDQTTY, sum(RELEVSDQTTY) RELEVSDQTTY from dfmast group by groupid) dfmast, dfgroup df
    LEFT JOIN LNSCHD LNS ON DF.LNACCTNO = LNS.ACCTNO AND LNS.REFTYPE=''P''
where df.afacctno= af.acctno and af.acctno=ci.acctno and af.custid= cf.custid and df.actype=dftype.actype
and A4.cdname = ''RRTYPE'' and A4.cdtype =''DF'' AND A4.CDVAL = DF.RRTYPE AND dftype.isvsd=''Y''
and df.groupid = dfmast.groupid
and A5.cdname = ''DEALSTATUS'' and A5.cdtype =''DF'' AND A5.CDVAL = decode(DF.STATUS,''N'',''P'',DF.STATUS)
and A6.cdname = ''DEALVSDSTATUS'' and A6.cdtype =''DF''
AND A6.CDVAL = case when nvl(dfmast.RELEVSDQTTY,0) > 0 and df.isvsd = ''Y'' then ''R''
                    when nvl(dfmast.SENDVSDQTTY,0) = 0 and df.isvsd = ''N'' then ''P''
                    when nvl(dfmast.SENDVSDQTTY,0) > 0 and df.isvsd = ''N'' then ''W''
                    when df.status in (''A'',''C'',''R'') and nvl(dfmast.RELEVSDQTTY,0) = 0 and df.isvsd = ''Y'' then ''N''
                    when df.isvsd = ''Y'' then ''A''
                    else ''N'' end', 'DFGROUP', 'frmViewDFMAST', 'GROUPID DESC', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;