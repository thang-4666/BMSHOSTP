SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CAMAST_2225','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CAMAST_2225', 'Quản lý thực hiện quyền', 'Coporate action management', '
SELECT CAMAST.CAMASTID VALUE,CAMAST.AUTOID,SYM.SYMBOL,SUBSTR(CAMAST.CAMASTID,1,4)||''.''||SUBSTR(CAMAST.CAMASTID,5,6)||''.''||SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
CAMAST.CODEID, CAMAST.EXCODEID, A1.CDVAL TYPEID, A1.CDCONTENT CATYPE,REPORTDATE ,DUEDATE,ACTIONDATE ,BEGINDATE, EXPRICE, EXRATE, RIGHTOFFRATE, DEVIDENTRATE,OPTCODEID,
 DEVIDENTSHARES, SPLITRATE, INTERESTRATE, CAMAST.DESCRIPTION,CAMAST.DESCRIPTION CONTENTS, INTERESTPERIOD, A2.CDCONTENT STATUS, FRDATERETAIL, TODATERETAIL, TRFLIMIT,
 (case when CAMAST.CATYPE=''014'' then CAMAST.EXPRICE end) ROPRICE,
 (case when CAMAST.CATYPE=''011'' then CAMAST.EXPRICE end) TVPRICE,
(CASE WHEN EXRATE IS NOT NULL THEN EXRATE ELSE (CASE WHEN RIGHTOFFRATE IS NOT NULL
       THEN RIGHTOFFRATE ELSE (CASE WHEN DEVIDENTRATE IS NOT NULL THEN DEVIDENTRATE  ELSE
       (CASE WHEN SPLITRATE IS NOT NULL THEN SPLITRATE ELSE (CASE WHEN INTERESTRATE IS NOT NULL
       THEN INTERESTRATE ELSE
       (CASE WHEN DEVIDENTSHARES IS NOT NULL THEN DEVIDENTSHARES ELSE ''0'' END)END)END)END) END)END) RATE, PITRATE, A3.CDVAL PITRATEMETHOD_CD, A3.CDCONTENT PITRATEMETHOD,
       CAMAST.CATYPE CATYPEVAL,FRDATETRANSFER,TODATETRANSFER,DEVIDENTVALUE,(CASE WHEN CAMAST.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
      PITRATESE,
     nvl(inactiondate,actiondate) INACTIONDATE, nvl(schd.amt,0) amt, nvl(schd.qtty,0) qtty,
    nvl(schd.taxamt,0) taxamt,nvl(schd.amtafter,0) amtafter,
    camast.status statusval, (case when camast.status=''S'' then 1 else 0 end) ISCHANGESTT,
    maker.tlname makerid,apprv.tlname apprvid,
    (case when CAMAST.CATYPE=''014'' then 1 else 0 end) ISRIGHTOFF,
    tosym.symbol TOSYMBOL, CAMAST.ISINCODE
 FROM  CAMAST, SBSECURITIES SYM, ALLCODE A1, ALLCODE A2, ALLCODE A3,
      (select sum(case when schd.isci= ''Y'' then schd.amt else 0 end) amt,
         sum( case when schd.isse =''Y'' then schd.qtty else 0 end) qtty,
         sum(round(mst.pitrate *
                       ( CASE WHEN
                              (CASE WHEN schd.pitratemethod=''##'' THEN mst.pitratemethod ELSE schd.pitratemethod END) =''SC''
                         THEN 1 ELSE 0 END)
                        *(case when ( schd.isci= ''Y'' and cf.vat=''Y'') then (case when  mst.catype=''016'' then schd.intamt else schd.amt end)
                               else 0 end) /100
            ))taxamt,
      sum((case when schd.isci= ''Y'' then schd.amt else 0 end) - ROUND(mst.pitrate
                         * ( CASE WHEN
                              (CASE WHEN schd.pitratemethod=''##'' THEN mst.pitratemethod ELSE schd.pitratemethod END) =''SC''
                         THEN 0 ELSE 1 END)
             *(case when (schd.isci= ''Y'' and cf.vat=''Y'') then (case when  mst.catype=''016'' then schd.intamt else schd.amt end)
                               else 0 end) /100
            ))amtafter,
         schd.camastid
          from caschd schd,camast mst,afmast af, aftype aft, cfmast cf
          where schd.deltd=''N''
          and mst.deltd=''N''
          and af.custid = cf.custid
          AND mst.camastid=schd.camastid
          and schd.afacctno=af.acctno
          and af.actype=aft.actype
          group by schd.camastid) SCHD,
 tlprofiles maker, tlprofiles apprv,
 sbsecurities TOSYM
 WHERE CAMAST.CODEID=SYM.CODEID AND A1.CDTYPE = ''CA''
 AND A1.CDNAME = ''CATYPE'' AND A1.CDVAL=CATYPE
 and A3.CDTYPE=''CA'' AND A3.CDNAME=''PITRATEMETHOD'' AND CAMAST.PITRATEMETHOD =A3.CDVAL
 AND A2.CDTYPE = ''CA'' AND A2.CDNAME = ''CASTATUS''
 AND CAMAST.STATUS=A2.CDVAL AND CAMAST.DELTD =''N''
 and camast.camastid=schd.camastid(+)
 and camast.makerid=maker.tlid(+) and camast.apprvid=apprv.tlid(+)
 and camast.status in (''V'',''I'',''H'',''G'',''J'',''M'',''S'',''B'')
 and nvl(camast.tocodeid,camast.codeid)=tosym.codeid', 'CAMAST', '', 'AUTOID DESC', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;