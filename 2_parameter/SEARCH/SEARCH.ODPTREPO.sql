SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ODPTREPO','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ODPTREPO', 'Lệnh thỏa thuận Repo', 'Order Repo', '
select * from (SELECT OD.ORDERID ORDERID,max(CF.CUSTODYCD) CUSTODYCD ,max(CF.FULLNAME) FULLNAME,
max(AF.ACCTNO) AFACCTNO , max(OD.TXDATE) TXDATE,
max(OD.QUOTEPRICE)  QUOTEPRICE, max(OD.ORDERQTTY) ORDERQTTY, max(SB.SYMBOL) SYMBOL , max(OD.CLEARDAY) CLEARDAY,
max(TBL.EXECTYPE) EXECTYPE,
max(NVL(TBL.PRICE2,0)) PRICE2, max(NVL(TBL.EXPTDATE,''01-JAN-2000'' )) EXPTDATE,
max(NVL(CF2.CUSTODYCD,'''')) REF_CUSTODYCD,max(TBL.REF_AFACCTNO) REF_AFACCTNO, max(NVL(CF2.FULLNAME,'''')) REF_FULLNAME,
max(CASE WHEN TBL.REF_CUSTODYCD IS NULL THEN ''2'' ELSE ''1'' END) FIRM,
max(CASE  WHEN tbl.txdate < fn_get_prevdate(CA.REPORTDATE,2) AND tbl.exptdate>= fn_get_prevdate(CA.REPORTDATE,2) THEN
nvl(ca.DESCRIPTION,'''') ELSE '''' END)  CA_DESC,
max(GREATEST(OD.execqtty,FN_GET_GRP_EXEC_QTTY (OD.ORDERID))) EXECQTTY,--soluong khop lan 1
max(GREATEST(OD2.execqtty,FN_GET_GRP_EXEC_QTTY (OD2.ORDERID))) EXECQTTY2,--soluong khop lan 2
max(nvl(OD2.QUOTEPRICE,0))  QUOTEPRICE2, max(nvl(OD2.ORDERQTTY,0)) ORDERQTTY2,
max(CD.cdcontent) orstatus, max(cd2.cdcontent) GRPORDER,max(tbl.REF_ORDERID) REF_ORDERID,
max(NVL(OD2.orderid,0))  orderid2,
max(case when od3.execqtty > 0 or (od3.remainqtty>0 and OD3.txdate =to_date(sys.varvalue,''DD/MM/RRRR''))  THEN tbl.ref_orderid2 else '''' end) REF_ORDERID2,
MAX(OD.remainqtty) remainqtty, MAX(sys.varvalue) CURRDATE,
max(od2.txdate) od2_txdate,max(nvl(OD2.remainQTTY,0)) REMAINQTTY2
FROM  AFMAST AF, CFMAST CF,
    VW_ODMAST_ALL OD, --Lenh goc
    SBSECURITIES SB,allcode CD,allcode CD2,
    TBL_ODREPO TBL,
    CFMAST CF2,
    (SELECT  CODEID, REPORTDATE ,DESCRIPTION FROM CAMAST
        WHERE CATYPE IN (''015'',''016'') AND DELTD=''N'' AND STATUS <> ''P''
        UNION ALL
        SELECT codeid, to_date(''01-Jan-2000'',''DD/MM/RRRR'') REPORTDATE,'''' DESCRIPTION FROM sbsecurities
        WHERE sectype IN (''003'',''006'')
    ) CA,
    (select * from
       VW_ODMAST_ALL od
        where (CASE WHEN OD.GRPORDER =''Y'' THEN ''N'' ELSE  OD.DELTD END )= ''N''
        AND (CASE WHEN OD.GRPORDER =''Y'' THEN fn_get_grp_cancel_qtty(OD.orderid) ELSE  OD.CANCELQTTY END )=0
        AND OD.MATCHTYPE = ''P''
     ) OD2,--, --Lenh mua hoac ban lai
     (select * from
       VW_ODMAST_ALL od
        where (CASE WHEN OD.GRPORDER =''Y'' THEN ''N'' ELSE  OD.DELTD END )= ''N''
        AND (CASE WHEN OD.GRPORDER =''Y'' THEN 0 ELSE  OD.CANCELQTTY END )=0
        AND OD.MATCHTYPE = ''P''
     ) OD3, sysvar sys
WHERE CF.CUSTID = AF.CUSTID
    AND OD.AFACCTNO = AF.ACCTNO
    AND OD.CODEID = SB.CODEID
    AND OD.MATCHTYPE = ''P''
    and cd.cdname = ''ORSTATUS'' and cd.cdtype=''OD''
    and cd.cdval = od.orstatus
    and  cd2.cdtype =''SY'' AND  cd2.cdname =''YESNO''
    and od.GRPORDER = cd2.cdval
    AND (CASE WHEN OD.GRPORDER =''Y'' THEN ''N'' ELSE  OD.DELTD END )= ''N''
    AND OD.ORDERID = TBL.ORDERID
    AND TBL.REF_CUSTODYCD = CF2.CUSTODYCD(+)
    AND TBL.ORDERID2 = OD2.ORDERID(+)
    AND TBL.REF_ORDERID2 = OD3.ORDERID(+)
    AND tbl.codeid = ca.CODEID
    and sys.grname =''SYSTEM'' and sys.varname =''CURRDATE''
    GROUP BY OD.ORDERID ) od where 0=0
    AND (GREATEST(od.execqtty,FN_GET_GRP_EXEC_QTTY (OD.ORDERID)) > 0
            --or (od.remainqtty>0 and OD.txdate =to_date(CURRDATE,''DD/MM/RRRR''))
            --OR (fn_get_grp_remain_qtty(OD.ORDERID) >0 AND OD.txdate =to_date(CURRDATE,''DD/MM/RRRR''))
        )
    and ((nvl(EXECQTTY2,0) = 0 and nvl(od2_txdate,to_date(''01/01/2000'',''DD/MM/RRRR'')) <> to_date(CURRDATE,''DD/MM/RRRR''))
            or  (nvl(REMAINQTTY2,0) = 0 and nvl(od2_txdate,to_date(''01/01/2000'',''DD/MM/RRRR'')) = to_date(CURRDATE,''DD/MM/RRRR''))
            OR (fn_get_grp_remain_qtty(ORDERID2) >0 AND nvl(od2_txdate,to_date(''01/01/2000'',''DD/MM/RRRR'')) =to_date(CURRDATE,''DD/MM/RRRR''))
        )
	and nvl(OD.orderid2,''0'') = ''0''
', 'ODPTREPO', 'frmODMAST', 'ORDERID DESC', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;