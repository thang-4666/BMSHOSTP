SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF2669','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF2669', 'Gia hạn hợp đồng vay (Giao dịch 2669)', 'Gia hạn hợp đồng vay (Giao dịch 2669)', 'select lnc.autoid ,lnc.acctno , ln.trfacctno afacctno, cf.fullname CUSTNAME,cf.idcode LICENSE,
cf.address,cf.custodycd,lnc.overduedate,lnc.rlsdate,lntype.typename  PRODUCTNAME,
ROUND(lnc.nml) AMT,
ROUND(lnc.intnmlacr+lnc.intdue) ointnmlacr,ROUND(lnc.feeintnmlacr+lnc.feeintdue) ofeeintnmlacr,
ROUND(lnc.intnmlacr+lnc.intdue) intnmlacr,ROUND(lnc.feeintnmlacr+lnc.feeintdue) feeintnmlacr,
ROUND(lnc.intnmlacr+lnc.intdue) + ROUND(lnc.feeintnmlacr+lnc.feeintdue) totalint,
lnc.rate1 orate1, lnc.rate2 orate2, lnc.rate3 orate3, lnc.cfrate1 ocfrate1, lnc.cfrate2 ocfrate2, lnc.cfrate3 ocfrate3, c1.cdcontent autoapply_desc,
lnc.rate1, lnc.rate2, lnc.rate3, lnc.cfrate1, lnc.cfrate2, lnc.cfrate3, ln.autoapply, ln.autoapply oautoapply, dfg.rttdf
from  lnschd lnc , lnmast ln, afmast af , cfmast cf,lntype, sysvar sys, allcode c1,
DFGROUP DF, v_getgrpdealformular dfg
where lnc.acctno = ln.acctno and ln.trfacctno= af.acctno
AND LN.ACCTNO = DF.LNACCTNO and df.groupid = dfg.groupid
and dfg.rttdf>= df.irate
and af.custid = cf.custid  and lntype.actype= ln.actype
and sys.grname = ''SYSTEM'' and sys.varname = ''CURRDATE''
and to_date(sys.varvalue,''DD/MM/RRRR'') between lnc.overduedate - lntype.exdays and lnc.overduedate
and lnc.reftype = ''P'' and ln.ftype = ''DF''  and lnc.extimes < lntype.extimes
and c1.cdtype = ''LN'' and c1.cdname = ''AUTOAPPLY'' and c1.cdval = ln.autoapply', 'SEMAST', 'frmSEMAST', '', '2669', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', 'CUSTODYCD', 'N', '', 'CUSTODYCD');COMMIT;