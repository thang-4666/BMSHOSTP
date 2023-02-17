SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3356','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3356', 'Chuyển chứng khoán thực hiện quyền thành giao dịch(gd 3356)', 'Chuyển chứng khoán thực hiện quyền thành giao dịch(gd 3356)', '
select mst.*,se.qtty, (se.qtty-realqtty) diffqtty from
(select max(mstautoid) AUTOID,camastid ,max(description)
description, max(type) type,max(tradedate)tradedate,max
(parvalue) parvalue,
max(price) price,sum(trade) trade,sum(blocked)
blocked,max(CODEID) codeid, max(symbol) symbol, max
(catype) catype,
sum(caqtty) caqtty,SUM(realqtty) realqtty,max(codeidwft)
codeidwft,max(isincode) isincode
from (SELECT camast.autoid
mstautoid,ca.autoid,camast.camastid, camast.description,
''001'' type,
camast.tradedate ,sb.parvalue, SE.costprice PRICE ,
CF.CUSTODYCD,CF.CUSTID,
 af.acctno AFACCTNO,SB.CODEID,
cf.fullname,cf.idcode,cf.address,sb.symbol,se.STATUS,
AF.ACCTNO||SB.CODEID SEACCTNOCR,AF.ACCTNO||sbwft.CODEID
SEACCTNODR,
least(ca.qtty,se.trade) TRADE ,(case when
(ca.qtty>se.trade) then least((ca.qtty-
se.trade),se.blocked) else 0 end) blocked,a1.cdcontent
catype,
ca.qtty caqtty, (least(ca.qtty,se.trade) +  (case when
(ca.qtty>se.trade) then least((ca.qtty-
se.trade),se.blocked) else 0 end)) realqtty,
sbwft.codeid codeidwft, camast.isincode
From vw_camast_all camast , vw_caschd_all ca,semast se
,afmast af,cfmast cf , sbsecurities sb ,sbsecurities
sbwft, SECURITIES_INFO SEINFO,
allcode a1
where camast.camastid = ca.camastid
and camast.ISWFT=''Y'' and ca.ISSE=''Y''
and  nvl(camast.tocodeid,camast.codeid) = sb.codeid and
ca.afacctno= se.afacctno
and se.afacctno = af.acctno and af.custid = cf.custid
and sb.codeid = seinfo.codeid
and se.codeid = sbwft.codeid and
sbwft.refcodeid=sb.codeid /* and se.trade+se.blocked>0*/
and a1.cdval=camast.catype and a1.cdname=''CATYPE'' and
a1.cdtype=''CA''
and sbwft.tradeplace=''006'' and ca.status in
(''C'',''S'',''G'',''H'',''J'')
and ca.status <> ''C''
and  instr(nvl(ca.pstatus,''A''),''W'') <=0
)
group by camastid,isincode) mst,
(SELECT codeid,SUM( se2.TRADE + se2.MORTAGE +
se2.STANDING+se2.WITHDRAW+se2.DEPOSIT+se2.BLOCKED
+se2.SENDDEPOSIT+se2.DTOCLOSE) qtty FROM semast se2
GROUP BY codeid) se where mst.codeidwft=se.codeid', 'SEMAST', 'frmSEMAST', 'AUTOID DESC', '3356', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;