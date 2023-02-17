SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CA1012
(AFACCTNO, VALUE, AUTOID, SYMBOL, CAMASTID, 
 CODEID, EXCODEID, TYPEID, CATYPE, REPORTDATE, 
 DUEDATE, ACTIONDATE, BEGINDATE, EXPRICE, EXRATE, 
 RIGHTOFFRATE, DEVIDENTRATE, OPTCODEID, DEVIDENTSHARES, SPLITRATE, 
 INTERESTRATE, DESCRIPTION, CONTENTS, INTERESTPERIOD, STATUS, 
 FRDATERETAIL, TODATERETAIL, TRFLIMIT, ROPRICE, TVPRICE, 
 RATE, PITRATE, PITRATEMETHOD_CD, PITRATEMETHOD, CATYPEVAL, 
 FRDATETRANSFER, TODATETRANSFER, DEVIDENTVALUE, APRALLOW, PITRATESE, 
 INACTIONDATE, AMT, QTTY, TAXAMT, AMTAFTER, 
 STATUSVAL, ISCHANGESTT, MAKERID, APPRVID, ISRIGHTOFF, 
 TRADE, TOSYMBOL, TOCODEID, CAQTTY)
BEQUEATH DEFINER
AS 
(
SELECT CASCHD.AFACCTNO, CAMAST.CAMASTID VALUE,CAMAST.AUTOID,SYM.SYMBOL,SUBSTR(CAMAST.CAMASTID,1,4)||'.'||SUBSTR(CAMAST.CAMASTID,5,6)||'.'||SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
CAMAST.CODEID, CAMAST.EXCODEID, A1.CDVAL TYPEID, A1.CDCONTENT CATYPE,REPORTDATE ,DUEDATE,ACTIONDATE ,BEGINDATE, EXPRICE, EXRATE, RIGHTOFFRATE, DEVIDENTRATE,OPTCODEID,
 DEVIDENTSHARES, SPLITRATE, INTERESTRATE, CAMAST.DESCRIPTION,CAMAST.DESCRIPTION CONTENTS, INTERESTPERIOD, A2.CDCONTENT STATUS, FRDATERETAIL, TODATERETAIL, TRFLIMIT,
 (case when CAMAST.CATYPE='014' then CAMAST.EXPRICE end) ROPRICE,
 (case when CAMAST.CATYPE='011' then CAMAST.EXPRICE end) TVPRICE,
(CASE WHEN EXRATE IS NOT NULL THEN EXRATE ELSE (CASE WHEN RIGHTOFFRATE IS NOT NULL
       THEN RIGHTOFFRATE ELSE (CASE WHEN DEVIDENTRATE IS NOT NULL THEN DEVIDENTRATE  ELSE
       (CASE WHEN SPLITRATE IS NOT NULL THEN SPLITRATE ELSE (CASE WHEN INTERESTRATE IS NOT NULL
       THEN INTERESTRATE ELSE
       (CASE WHEN DEVIDENTSHARES IS NOT NULL THEN DEVIDENTSHARES ELSE '0' END)END)END)END) END)END) RATE, PITRATE, A3.CDVAL PITRATEMETHOD_CD, A3.CDCONTENT PITRATEMETHOD,
       CAMAST.CATYPE CATYPEVAL,FRDATETRANSFER,TODATETRANSFER,DEVIDENTVALUE,(CASE WHEN CAMAST.STATUS IN ('P') THEN 'Y' ELSE 'N' END) APRALLOW,
      PITRATESE,
     nvl(inactiondate,actiondate) INACTIONDATE, nvl(schd.amt,0) amt, nvl(schd.qtty,0) qtty,
    nvl(schd.taxamt,0) taxamt,nvl(schd.amtafter,0) amtafter,
    camast.status statusval, (case when camast.status='S' then 1 else 0 end) ISCHANGESTT,
    maker.tlname makerid,apprv.tlname apprvid,
    (case when CAMAST.CATYPE='014' then 1 else 0 end) ISRIGHTOFF,
    nvl(schd2.TRADE,0) trade,
    tosym.symbol tosymbol,NVL(camast.tocodeid,camast.codeid) tocodeid,
    nvl(schd2.QTTY,0) CAQTTY
 FROM  CAMAST, CASCHD, SBSECURITIES SYM, ALLCODE A1, ALLCODE A2, ALLCODE A3,
      (select sum(case when schd.isci= 'Y' then schd.amt else 0 end) amt,
         sum( case when schd.isse ='Y' then schd.qtty else 0 end) qtty,
         sum(round(mst.pitrate *
                       ( CASE WHEN
                              (CASE WHEN schd.pitratemethod='##' THEN mst.pitratemethod ELSE schd.pitratemethod END) ='SC'
                         THEN 1 ELSE 0 END)
                        *(case when ( schd.isci= 'Y' and cf.vat='Y') then (case when  mst.catype='016' then schd.intamt else schd.amt end)
                               else 0 end) /100
            ))taxamt,
      sum((case when schd.isci= 'Y' then schd.amt else 0 end) - ROUND(mst.pitrate
                         * ( CASE WHEN
                              (CASE WHEN schd.pitratemethod='##' THEN mst.pitratemethod ELSE schd.pitratemethod END) ='SC'
                         THEN 0 ELSE 1 END)
             *(case when (schd.isci= 'Y' and cf.vat='Y') then (case when  mst.catype='016' then schd.intamt else schd.amt end)
                               else 0 end) /100
            ))amtafter,
         schd.camastid
          from caschd schd,camast mst,afmast af, aftype aft, cfmast cf
          where schd.deltd='N'
          and mst.deltd='N' and af.custid = cf.custid
          AND mst.camastid=schd.camastid
          and schd.afacctno=af.acctno
          and af.actype=aft.actype
          group by schd.camastid) SCHD,
 tlprofiles maker, tlprofiles apprv,
 (SELECT SUM(nvl(trade,0)) trade, SUM(nvl(QTTY,0)) QTTY, camastid from caschd WHERE deltd='N' AND isexec <> 'N' GROUP BY camastid) schd2,
 SBSECURITIES TOSYM
 WHERE CAMAST.CODEID=SYM.CODEID AND A1.CDTYPE = 'CA' AND CAMAST.CAMASTID = CASCHD.CAMASTID
 AND A1.CDNAME = 'CATYPE' AND A1.CDVAL=CATYPE
 and A3.CDTYPE='CA' AND A3.CDNAME='PITRATEMETHOD' AND CAMAST.PITRATEMETHOD =A3.CDVAL
 AND A2.CDTYPE = 'CA' AND A2.CDNAME = 'CASTATUS'
 AND CAMAST.STATUS=A2.CDVAL AND CAMAST.DELTD ='N'
 and camast.camastid=schd.camastid(+)
 and camast.makerid=maker.tlid(+) and camast.apprvid=apprv.tlid(+)
 AND camast.camastid=schd2.camastid(+)
 AND NVL(camast.tocodeid,camast.codeid)=tosym.codeid
 AND CASCHD.deltd <> 'Y'
)
/
