SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2263','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2263', 'Chuyển chứng khoán chờ giao dịch thành giao dịch (Giao dịch 2263)', 'View account transfer to other account(wait for 2263)', 'select sb.parvalue, SE.COSTPRICE PRICE , CF.CUSTODYCD,CF.CUSTID, af.acctno AFACCTNO,SB.CODEID,
 cf.fullname custname,cf.idcode LICENSE,cf.address,sb.symbol,se.STATUS,AF.ACCTNO||SB.CODEID SEACCTNOCR,AF.ACCTNO||sbwft.CODEID SEACCTNODR,
 (case when (se.TRADE-nvl(ca.qtty,0))>0 then se.TRADE-nvl(ca.qtty,0) else 0 end ) TRADE ,
 (case when (se.TRADE-nvl(ca.qtty,0))>0 then se.TRADE-nvl(ca.qtty,0) else 0 end ) TRADE2,
  se.MORTAGE+ se.STANDING MORTAGE,se.MARGIN ,se.NETTING,
 se.STANDING,se.WITHDRAW,se.DEPOSIT,se.LOAN,se.WITHDRAW WITHDRAW2,
 se.BLOCKED, se.BLOCKED BLOCKED2,se.emkqtty , se.emkqtty emkqtty2,
 se.blockwithdraw,  se.blockwithdraw blockwithdraw2,
 se.blockdtoclose, se.blockdtoclose blockdtoclose2,
 se.RECEIVING,se.TRANSFER,se.SENDDEPOSIT,
 se.SENDPENDING,se.DTOCLOSE,se.SDTOCLOSE,A0.CDCONTENT PRODUCTTYPE
 from semast se , afmast af , AFTYPE AFT,ALLCODE A0, cfmast cf, sbsecurities sb ,sbsecurities sbwft,
   (SELECT sum(schd.qtty) qtty ,(schd.afacctno ||symwft.codeid )seacctno
    from caschd schd,camast ca , sbsecurities symwft
    WHERE ca.camastid=schd.camastid AND schd.deltd=''N'' AND schd.ISSE=''Y''
    /*AND ca.catype=''026''*/
    AND ca.iswft=''Y'' AND ca.deltd=''N''
    AND NVL(ca.tocodeid,ca.codeid)= symwft.refcodeid
    AND (INSTR(nvl(schd.pstatus,''A''),''W'')= 0 and schd.status not in (''W'',''C'')) GROUP BY schd.afacctno,symwft.codeid) ca,
( SELECT max( decode (fldcd,''03'',cvalue))seacctno, max( decode (fldcd,''10'',nvalue))trade ,
max( decode (fldcd,''16'',nvalue))WITHDRAW ,max( decode (fldcd,''15'',nvalue))STANDING ,max( decode (fldcd,''22'',nvalue))SENDDEPOSIT ,
max( decode (fldcd,''12'',nvalue))MORTAGE ,max( decode (fldcd,''39'',nvalue))EMKQTTY ,max( decode (fldcd,''25'',nvalue))DTOCLOSE,
max( decode (fldcd,''17'',nvalue))DEPOSIT, max( decode (fldcd,''27'',nvalue))BLOCKWITHDRAW, max( decode (fldcd,''19'',nvalue))BLOCKED,
max( decode (fldcd,''28'',nvalue))BLOCKDTOCLOSE
FROM tllog4dr tl,tllogfld4dr tlfld
WHERE tl.txnum = tlfld.txnum AND tl.txdate = tlfld.txdate
AND tltxcd =''2263''   and tl.deltd <> ''Y'' and tl.txstatus =''4''
and not  EXISTS (select 1 from tllog t where t.txnum = tl.txnum and t.deltd<>''Y'' and txstatus =''1'')
) DTL
where se.afacctno = af.acctno and af.custid = cf.custid
and se.codeid = sbwft.codeid and sbwft.refcodeid=sb.codeid
AND AF.ACTYPE=AFT.ACTYPE AND A0.CDTYPE=''CF'' AND A0.CDNAME=''PRODUCTTYPE'' AND AFT.PRODUCTTYPE=A0.CDVAL
and sbwft.tradeplace=''006''
AND SE.acctno = DTL.seacctno(+)
AND se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE+se.blockwithdraw+se.blockdtoclose+se.emkqtty
- NVL(dtl.trade,0)-  NVL(dtl.MORTAGE,0)- NVL(dtl.STANDING,0)- NVL(dtl.WITHDRAW,0)- NVL(dtl.DEPOSIT,0)- NVL(dtl.SENDDEPOSIT,0)-
 NVL(dtl.DTOCLOSE,0)-  NVL(dtl.blockwithdraw,0)- NVL(dtl.blockdtoclose,0)- NVL(dtl.emkqtty,0)-NVL(dtl.blocked,0)>0
and se.acctno= ca.seacctno(+)
and se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE >nvl(ca.qtty,0)', 'SEMAST', 'frmSEMAST', '', '2263', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;