SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA9999','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA9999', 'Thực hiện quyền phân bổ tiền vào tài khoản', 'Money execute CA', 'select * from (
    select max(A.AUTOID) AUTOID,a.camastid, a.description, b.symbol, a.actiondate ,a.actiondate POSTINGDATE,
        sum (
            (case when a.catype = ''010'' then (case when chd.status = ''K'' then round((100-a.exerate)/100,4) else round(a.exerate/100,4) end) else 1 end)
                *(case when (case when chd.PITRATEMETHOD <> ''##'' then chd.PITRATEMETHOD else a.PITRATEMETHOD end) = ''SC'' or cf.vat=''N''
                then chd.amt else (CASE WHEN a.catype in (''016'',''023'')
                THEN round(chd.amt-round(chd.intamt*a.pitrate/100))
                ELSE round(chd.amt-round(chd.amt*a.pitrate/100)) end
                ) END)
        )allamt,
        sum(chd.amt) amt,
        sum (case when (case when chd.PITRATEMETHOD <>''##'' then chd.PITRATEMETHOD else a.PITRATEMETHOD end)    = ''SC'' and cf.vat=''Y''
            then (CASE WHEN a.catype in (''016'',''023'') THEN round (chd.intamt * a.pitrate/100) ELSE round( chd.amt * a.pitrate/100) END ) else 0 end) scvatamt,
        max(cd.cdcontent) catype,
        max(a.codeid) codeid, a.isincode,
        max(TX.txdesc)  TXDESC
    from camast a, sbsecurities b , caschd chd,allcode cd, afmast af, aftype aft, cfmast cf, TLTX TX
    where a.codeid = b.codeid and a.status  in (''I'',''G'',''H'',''K'')
        and chd.afacctno = af.acctno and af.actype = aft.actype and af.custid = cf.custid
        and a.deltd<>''Y'' AND TX.TLTXCD = ''3342''
        and a.camastid = chd.camastid
        and chd.deltd <> ''Y'' and chd.ISEXEC=''Y''
        and chd.status <> ''C'' and chd.isCI =''N''
        and (select count(1) from caschd where camastid = a.camastid and status <> ''C'' and isCI =''N'' AND ISEXEC=''Y'' and amt>0 and deltd=''N'') >0
        and cd.cdname =''CATYPE'' and cd.cdtype =''CA'' and cd.cdval = a.catype
        group by a.isincode,a.camastid, a.description, b.symbol, a.actiondate
        having sum(chd.amt) <>0
) where 0 = 0', 'CAMAST', '', 'AUTOID DESC', 'EXEC', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;