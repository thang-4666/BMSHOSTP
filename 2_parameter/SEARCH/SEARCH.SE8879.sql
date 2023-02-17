SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE8879','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE8879', 'Tra cứu giao dịch bán chứng khoán lô lẻ chưa thanh toán chứng khoán', 'View match securities order retail', 'SELECT FN_GET_LOCATION(AF.BRID) LOCATION, CF.CUSTODYCD, B.DESACCTNO AFDDI , C.CODEID, C.SYMBOL, C.PARVALUE, A.AFACCTNO,
    to_char(B.TXDATE,''dd/mm/yyyy'') txdate,b.TXNUM,b.ACCTNO,b.PRICE,b.QTTY,b.STATUS,b.DESACCTNO,b.FEEAMT,b.TAXAMT,b.SDATE,b.VDATE,
    CF.IDCODE ,A4.CDCONTENT TRADEPLACE,CASE WHEN CI.COREBANK=''Y'' THEN 0 ELSE 1 END ISCOREBANK,
    ROUND(decode(CF.VAT,''Y'',1,0)* B.QTTY*b.price/100*(SELECT to_number(varvalue) FROM SYSVAR WHERE VARNAME =''ADVSELLDUTY'')) TAX,
    CI.DEPOLASTDT, /*(case when tl.fldcd = ''18'' then nvl(tl.nvalue,0) else 0 end)*/least(B.qtty,nvl(sp.qtty,0)) pitqtty,
    /*0*/round(GREATEST(least(B.qtty,nvl(sp.qtty,0))*LEAST(b.price,c.parvalue),0)*nvl(sp.pitrate,0)) pitamt,cf.fullname,
    to_char(B.TXDATE,''dd/mm/yyyy'') || b.TXNUM ACCREF
FROM SEMAST A, SERETAIL B, SBSECURITIES C ,AFMAST AF , CFMAST CF ,ALLCODE A4,AFTYPE afTY,CIMAST CI ,
    --vw_tllogfld_all tl
    (SELECT se.afacctno, se.codeid, GREATEST(SUM(se.qtty-nvl(se.mapqtty,0)),0) qtty, max(se.pitrate/100) pitrate
        FROM sepitlog se, securities_info sec
        WHERE se.codeid= sec.codeid and SE.PITRATE > 0 and se.deltd <> ''Y''
        group by se.afacctno, se.codeid 
    ) sp
WHERE A.ACCTNO = B.ACCTNO AND A.CODEID = C.CODEID AND B.QTTY > 0 AND B.STATUS=''S'' AND AF.ACCTNO =A.AFACCTNO AND AF.CUSTID =CF.CUSTID
AND A4.CDTYPE = ''SE'' AND A4.CDNAME = ''TRADEPLACE''  AND A4.CDVAL = C.TRADEPLACE
AND AF.ACTYPE=afty.actype and af.acctno=ci.acctno
--and B.txdate = tl.txdate and B.txnum = tl.txnum and tl.fldcd = ''18''
and a.afacctno = sp.afacctno(+)  and a.codeid = sp.codeid(+) 
AND to_char(B.TXDATE,''ddmmyyyy'')||B.TXNUM not in
(
    select NVL( MAX(CASE WHEN  FLDCD =''04'' THEN CVALUE END) || MAX( CASE WHEN  FLDCD =''05'' THEN CVALUE END),''-'') REF
    from tllog4dr tl, tllogfld4dr fld
    where tl.tltxcd =''8879''
    and tl.txnum = fld.txnum and tl.txdate = fld.txdate
    and tl.deltd <> ''Y'' and tl.txstatus =''4''
    and not  EXISTS (select 1 from tllog t where t.txnum = tl.txnum and t.deltd<>''Y'' and txstatus =''1'')
    GROUP BY  TL.TXDATE, TL.TXNUM
)', 'SEMAST', '', '', '8879', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;