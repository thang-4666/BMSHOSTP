SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF3003','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF3003', 'Theo dõi trạng thái Deal tổng bị TRIGGER', 'DF Deal Status', 'SELECT * FROM ( select al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,
AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DECODE(DF.LIMITCHK,''N'',0,1) LIMITCHECK ,
ROUND(DF.ORGAMT) -ROUND(DF.RLSAMT) AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
DF.TAX,DF.AMTMIN,DF.IRATE,DF.ARATE, DF.ALRATE, DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION, lns.rlsdate, lns.overduedate,
to_date (lns.overduedate,''DD/MM/RRRR'') - to_date ((SELECT VARVALUE FROM SYSVAR WHERE VARNAME=''CURRDATE''),''DD/MM/RRRR'') duenum,
(case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '''' end )
RRID , decode (df.RRTYPE,''O'',1,0) CIDRAWNDOWN,decode (df.RRTYPE,''B'',1,0) BANKDRAWNDOWN,
decode (df.RRTYPE,''C'',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,ROUND(LN.RLSAMT) AMTRLS,
LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3,
A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,TADF,
DDF, RTTDF RTT, ROUND(ODCALLDF) ODCALLDF, ODCALLSELLIRATE - NVL(od.sellamount,0) ODSELLDF, ODCALLRTTDF, ODCALLMRATE ODCALLRTTF,
ROUND(ODCALLSELLRCB) ODCALLSELLRCB, ROUND(ODCALLSELLARATE) ODCALLSELLARATE, ROUND(ODCALLSELLALRATE) ODCALLSELLALRATE,
ROUND(ODCALLSELLIRATE) ODCALLSELLIRATE ,
ROUND(ODCALLSELLMRATE) - ROUND(NVL(od.sellamount,0)) ODCALLSELLMR, ROUND(ODCALLSELLRXL) ODCALLSELLRXL,
ROUND(CURAMT) CURAMT, ROUND(CURINT) CURINT, ROUND(CURFEE) CURFEE, ROUND(LNS.PAID) PAID,
ROUND(DF.DFBLOCKAMT) DFBLOCKAMT, ROUND(vndselldf) vndselldf, ROUND(vndwithdrawdf) vndwithdrawdf, ROUND(ROUND(tadf) - ddf*(v.irate/100)) vwithdrawdf,
LEAST(ln.MInterm, TO_NUMBER( TO_DATE(lns.OVERDUEDATE,''DD/MM/RRRR'') - TO_DATE(lns.RLSDATE,''DD/MM/RRRR'')) )  MInterm, ln.intpaidmethod, lnt.WARNINGDAYS,
A4.CDCONTENT RRTYPENAME, CF.MOBILESMS FAX1, CF.EMAIL, ODDF, df.calldays,DFTYPE.DAYSNUMK1,
CASE WHEN DF.CALLDAYS>= DFTYPE.DAYSNUMK2 THEN ''Bán hết''
     else ''Bán đủ''
end SELLTYPE
from dfgroup df, dftype, lnmast ln, lntype lnt ,lnschd lns, afmast af , cfmast cf, allcode al1,
   ALLCODE A1, ALLCODE A2, ALLCODE A3, v_getgrpdealformular v , allcode A4, v_getdealsellamt od
where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype=''P'' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
and A1.cdname = ''YESNO'' and A1.cdtype =''SY'' AND A1.CDVAL = LN.PREPAID
and A2.cdname = ''INTPAIDMETHOD'' and A2.cdtype =''LN'' AND A2.CDVAL = LN.INTPAIDMETHOD
and A3.cdname = ''AUTOAPPLY'' and a3.cdtype =''LN'' AND A3.CDVAL = LN.AUTOAPPLY
and A4.cdname = ''RRTYPE'' and A4.cdtype =''DF'' AND A4.CDVAL = DF.RRTYPE
and df.flagtrigger=al1.cdval and al1.cdname=''FLAGTRIGGER'' and df.groupid=v.groupid(+)
and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
) WHERE ODDF>0 AND ((RTT <= LRATE) or (calldays>=DAYSNUMK1 ) or (duenum<0) )', 'DFGROUP', 'frmViewDFMAST', 'GROUPID DESC', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;