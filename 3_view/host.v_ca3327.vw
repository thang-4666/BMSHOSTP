SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CA3327
(AUTOID, CAMASTID, CUSTODYCD, AFACCTNO, CODEID, 
 TOCODEID, SYMBOL, TOSYMBOL, IDDATE, IDPLACE, 
 REPORTDATE, PQTTY, TRADE, MAXQTTY, A, 
 B, QTTY, BEGINDATE, DUEDATE, ACCTNO, 
 FULLNAME, IDCODE, ISINCODE, ISFULLNAME, COUNTRY, 
 TRADINGCODE, QUOCGIA)
BEQUEATH DEFINER
AS 
(
SELECT schd.autoid,ca.camastid,cf.custodycd,af.acctno afacctno,sec1.codeid,sec2.codeid tocodeid,
sec1.symbol,sec2.symbol tosymbol,cf.iddate,cf.idplace,
ca.reportdate,schd.pqtty,schd.trade,(schd.pqtty+schd.qtty) maxqtty,substr(ca.exrate,0,instr(ca.exrate,'/') - 1) a,substr(ca.exrate,instr(ca.exrate,'/') + 1,length(ca.exrate)) b,
schd.qtty,ca.begindate,ca.duedate ,af.acctno,cf.fullname,cf.idcode, ca.isincode,iss.fullname ISfullname,a.cdcontent COUNTRY,cf.tradingcode,cf.country quocgia
FROM camast ca, caschd schd,cfmast cf, afmast af,sbsecurities sec1, sbsecurities sec2,ISSUERS ISs, allcode a
WHERE ca.camastid=schd.camastid
AND schd.afacctno=af.acctno AND af.custid=cf.custid
AND ca.codeid=sec1.codeid AND ca.tocodeid=sec2.codeid
AND to_date(ca.begindate,'DD/MM/YYYY') <= to_date(GETCURRDATE,'DD/MM/YYYY')
AND to_date(ca.duedate,'DD/MM/YYYY') >= to_date(GETCURRDATE,'DD/MM/YYYY')
AND ca.catype='023' AND schd.status='V'
AND schd.pqtty>=1
AND schd.deltd='N'
and iss.issuerid = sec1.issuerid
and a.cdname = 'COUNTRY'
and a.cdval = cf.country
 )
/
