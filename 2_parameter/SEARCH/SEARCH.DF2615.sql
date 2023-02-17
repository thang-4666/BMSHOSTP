SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF2615','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF2615', 'Giải tỏa cầm cố của VSD (2615)', '', 'select lns.autoid, DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO, SB.SYMBOL, SB.CODEID,
    (ABS(DF.dfstanding) - DF.RELEVSDQTTY) DFQTTY, DF.AFACCTNO || DF.CODEID SEACCTNO, DF.ACCTNO DFACCTNO,
    CF.ADDRESS,CF.IDCODE, DECODE(DF.LIMITCHK,''N'',0,1) LIMITCHECK ,
    DF.ORGAMT AMT, NVL(LNS.NML,0) + NVL(LNS.OVD,0) LNAMT, NVL(LNS.PAID,0) PAIDAMT , DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
    DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION,
    (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '''' end )
    RRID , decode (df.RRTYPE,''O'',1,0) CIDRAWNDOWN,decode (df.RRTYPE,''B'',1,0) BANKDRAWNDOWN,
    decode (df.RRTYPE,''C'',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,
    A4.CDCONTENT RRTYPENAME, CF.MOBILESMS, CF.EMAIL, ABS(DF.dfstanding) - DF.RELEVSDQTTY DFRLSQTTY
from dftype, afmast af , cfmast cf, allcode A4, SBSECURITIES SB,
    DFMAST DF
    LEFT JOIN LNSCHD LNS ON DF.LNACCTNO = LNS.ACCTNO AND LNS.REFTYPE=''P''
    LEFT JOIN (SELECT REFID, SUM(QTTY) SELLQTTY FROM ODMAPEXT WHERE DELTD <> ''Y'' GROUP BY REFID) ODM ON DF.ACCTNO = ODM.REFID
where df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
and A4.cdname = ''RRTYPE'' and A4.cdtype =''DF''
AND SB.CODEID = DF.CODEID AND A4.CDVAL = DF.RRTYPE
AND dftype.isvsd=''Y'' AND ABS(DF.dfstanding) > 0', 'DFGROUP', '', '', '2615', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;