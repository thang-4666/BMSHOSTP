SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3355','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3355', 'Chuyển chứng khoán thực hiện quyền thành giao dịch - từng tiểu khoản(GD 3355)', 'Chuyển chứng khoán thực hiện quyền thành giao dịch - từng tiểu khoản(GD 3355)', '
SELECT ca.autoid,camast.camastid, camast.description, ''001'' type,
camast.tradedate ,sb.parvalue, SE.costprice PRICE , CF.CUSTODYCD,CF.CUSTID, af.acctno AFACCTNO,SB.CODEID, cf.fullname,cf.idcode,cf.address,sb.symbol,A.cdcontent STATUS,
AF.ACCTNO||SB.CODEID SEACCTNOCR,AF.ACCTNO||sbwft.CODEID SEACCTNODR,
least(ca.qtty,se.trade) TRADE , (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end) blocked,
ca.qtty CAQTTY,(least(ca.qtty,se.trade)  + (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end)) realqtty,
( se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE) qtty,
(( se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE)- (least(ca.qtty,se.trade) +  (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end)) ) DIFFQTTY,
camast.isincode
From vw_camast_all camast , vw_caschd_all ca,semast se ,afmast af,cfmast cf , sbsecurities sb ,sbsecurities sbwft, SECURITIES_INFO SEINFO,
allcode A
where camast.camastid = ca.camastid
and camast.ISWFT=''Y'' and ca.ISSE=''Y''
and  nvl(camast.tocodeid,camast.codeid) = sb.codeid and ca.afacctno= se.afacctno
and se.afacctno = af.acctno and af.custid = cf.custid and sb.codeid = seinfo.codeid
and se.trade+se.blocked>0
and se.codeid = sbwft.codeid and sbwft.refcodeid=sb.codeid
and sbwft.tradeplace=''006'' and ca.status in(''C'',''S'',''G'',''H'',''J'')
and instr(nvl(ca.pstatus,''A''),''W'') <=0
and A.cdname=''STATUS'' and A.cdtype=''SE'' and A.cdval=se.status', 'SEMAST', 'frmSEMAST', '', '3355', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;