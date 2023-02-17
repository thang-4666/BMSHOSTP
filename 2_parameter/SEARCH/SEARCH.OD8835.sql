SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8835','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8835', 'Xóa lệnh khớp (8835)', 'Xóa lệnh khớp (wait for 8835)', 'select tl.txdate , tl.txnum ,tl.deltd, od.ORDERID,od.codeid,sb.symbol,cf.custodycd, cf.fullname
, af.acctno AFACCTNO,af.acctno ciacctno,od.orderqtty ORDERQTTY, od.quoteprice ORDERPRICE, io.matchprice MATCHPRICE,io.matchqtty MATCHQTTY,io.matchprice* io.matchqtty EXECAMT, AL.CDCONTENT EXECTYPE
from tllog tl, odmast od , sbsecurities sb, cfmast cf, afmast af,iod io,allcode al
where tl.msgacct= od.orderid and tl.tltxcd in(''8804'',''8809'')
and sb.codeid= od.codeid and od.afacctno = af.acctno
and af.custid= cf.custid and io.txnum= tl.txnum
and io.txdate = tl.txdate   and tl.deltd <>''Y'' AND OD.errod =''N''
and (SELECT COUNT(*) FROM sbbatchsts WHERE bchdate = getcurrdate AND bchsts =''Y'')=0
and al.cdtype =''OD'' AND AL.CDNAME=''EXECTYPE'' AND AL.CDVAL =OD.EXECTYPE', 'ODMAST', '', '', '8835', NULL, -1, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;