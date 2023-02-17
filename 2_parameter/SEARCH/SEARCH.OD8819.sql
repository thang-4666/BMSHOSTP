SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8819','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8819', 'Tra cứu trạng thái xác nhận lệnh', 'Order confirm status (wait for 8819)', 'SELECT OD.ORDERID,OD.TXDATE,OD.CODEID, A0.CDCONTENT TRADEPLACE, A1.CDCONTENT EXECTYPE,
od.PRICETYPE, A3.CDCONTENT VIA, OD.ORDERQTTY,OD.QUOTEPRICE, OD.REFORDERID,
se.symbol,a4.CDCONTENT CONFIRMED,od.afacctno, cf.custodycd, cf.fullname,
cspks_odproc.fn_OD_GetRootOrderID(od.orderid) ROOTORDERID,cf.pin,
(CASE WHEN NVL(CFMSTS.userid,''a'') <> ''a'' THEN CFMSTS.userid || '' - '' || tl.tlfullname
          WHEN  NVL(CFMSTS.custid,''a'') <> ''a'' THEN CFMSTS.custid || '' - '' || cf2.fullname
          ELSE  ''''  END) confirmdesc,
 to_date(substr(to_char(CFMSTS.cfmtime,''DD-MON-YYYY HH24:MI:SS''),1,11),''DD/MM/YYYY'') CFTXDATE
FROM CONFIRMODRSTS CFMSTS,
(select * from ODMAST union all select * from odmasthist where  txdate >=to_date(''01/01/2017'',''DD/MM/YYYY'')) OD, SBSECURITIES SE,
ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3,aLLCODE A4,
afmast af, cfmast cf, tlprofiles tl, cfmast cf2
WHERE CFMSTS.ORDERID(+)=OD.ORDERID
AND OD.CODEID=SE.CODEID
AND a0.cdtype = ''OD'' AND a0.cdname = ''TRADEPLACE'' AND a0.cdval = se.tradeplace
AND A1.cdtype = ''OD'' AND A1.cdname = ''EXECTYPE''
AND A1.cdval =(case when nvl(od.reforderid,''a'') <>''a'' and OD.EXECTYPE = ''NB'' then ''AB''
when  nvl(od.reforderid,''a'') <>''a'' and OD.EXECTYPE in ( ''NS'',''MS'') then ''AS''
  else od.EXECTYPE end)
AND A2.cdtype = ''OD'' AND A2.cdname = ''PRICETYPE'' AND A2.cdval = OD.PRICETYPE
AND A3.cdtype = ''OD'' AND A3.cdname = ''VIA'' AND A3.cdval = OD.VIA
AND a4.cdtype = ''SY'' AND a4.cdname = ''YESNO'' AND a4.cdval = nvl(CFMSTS.CONFIRMED,''N'')
/*and ( (od.exectype in (''NB'',''NS'',''MS'') AND od.via in (''F'',''T'')) or (od.exectype  not in (''NB'',''NS'',''MS'')))   */
and od.exectype not in (''AB'',''AS'')
and od.via in (''H'',''F'')
and od.afacctno=af.acctno and af.custid=cf.custid
AND nvl(cfMSTS.Custid,'''')=cf2.custid(+)
AND nvl(cfMSTS.Userid,'''')=tl.tlid(+)', 'ODMAST', '', ' TXDATE DESC, orderid asc', '8819', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;