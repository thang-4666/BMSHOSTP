SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SE2247
(ACCTNO, SYMBOL, AFACCTNO, TRADE, BLOCKED, 
 CODEID, PARVALUE, SELASTDATE, AFLASTDATE, LASTDATE, 
 CUSTODYCD, FULLNAME, IDCODE, TYPENAME, TRADEPLACE, 
 REFCUSTODYCD, REFINWARD, REFAFACCTNO, RIGHTQTTY, RIGHTOFFQTTY, 
 CAQTTYRECEIV, CAQTTYDB, CAAMTRECEIV, DESTTYPE, DESTTYPECD, 
 RIGHTQTTY_PENDING, RIGHTOFFQTTY_PENDING, CAQTTYRECEIV_PENDING, CAAMTRECEIV_PENDING)
BEQUEATH DEFINER
AS 
(SELECT SUBSTR(SEMAST.ACCTNO,1,4) || '.' || SUBSTR(SEMAST.ACCTNO,5,6) || '.' || SUBSTR(SEMAST.ACCTNO,11,6) ACCTNO, SYM.SYMBOL, SUBSTR(SEMAST.AFACCTNO,1,4) || '.' || SUBSTR(SEMAST.AFACCTNO,5,6) AFACCTNO,
SEMAST.TRADE TRADE, SEMAST.BLOCKED BLOCKED,SEMAST.CODEID, SYM.PARVALUE, SEMAST.LASTDATE SELASTDATE, AF.LASTDATE AFLASTDATE, NVL(SEMAST.LASTDATE,AF.LASTDATE) LASTDATE,
CF.CUSTODYCD,
CF.FULLNAME, CF.IDCODE, TYP.TYPENAME, A1.CDCONTENT TRADEPLACE, --ft.minval, ft.maxval,
SENDSETOCLOSE.REFCUSTODYCD,SENDSETOCLOSE.REFINWARD, SENDSETOCLOSE.REFAFACCTNO,
nvl(SCHD.RIGHTQTTY,0) RIGHTQTTY,nvl(SCHD.RIGHTOFFQTTY,0) RIGHTOFFQTTY,nvl(SCHD.CAQTTYRECEIV,0)CAQTTYRECEIV,
NVL((CASE WHEN SCHD.ISDBSEALL=1 THEN SEMAST.TRADE ELSE SCHD.CAQTTYDB END),0) CAQTTYDB,
nvl(schd.CAAMTRECEIV,0) CAAMTRECEIV, A2.cdcontent desttype, SENDSETOCLOSE.desttype desttypecd,
-- PhuongHT add them cho quyen moi lam den 3375
nvl(SCHD.RIGHTQTTY_PENDING,0) RIGHTQTTY_PENDING,nvl(SCHD.RIGHTOFFQTTY_PENDING,0) RIGHTOFFQTTY_PENDING,
nvl(SCHD.CAQTTYRECEIV_PENDING,0) CAQTTYRECEIV_PENDING ,nvl(schd.CAAMTRECEIV_PENDING,0) CAAMTRECEIV_PENDING
FROM (SELECT ACCTNO,ACTYPE,CODEID,AFACCTNO,OPNDATE,CLSDATE,LASTDATE,STATUS,PSTATUS,IRTIED,IRCD,COSTPRICE,TRADE,MORTAGE,MARGIN,
             NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN,BLOCKED,RECEIVING,TRANSFER,PREVQTTY,DCRQTTY,DCRAMT,DEPOFEEACR,REPO,
             PENDING,TBALDEPO,CUSTID,COSTDT,SECURED,ICCFCD,ICCFTIED,TBALDT,SENDDEPOSIT,SENDPENDING,DDROUTQTTY,DDROUTAMT,DTOCLOSE,
             SDTOCLOSE,QTTY_TRANSFER,LAST_CHANGE,DEALINTPAID,WTRADE,GRPORDAMT
      FROM SEMAST
      UNION ALL -- union them nhung tk co CA cho ve ma ko co SEMAST
      SELECT   distinct(schd.afacctno||schd.codeid) acctno,NULL,schd.CODEID, schd.AFACCTNO,NULL,NULL,NULL,'A',NULL,NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      af.custid,NULL,0,NULL,NULL,NULL,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL
      FROM (SELECT afacctno,codeid FROM caschd WHERE deltd='N'
            UNION ALL
            SELECT afacctno,tocodeid codeid FROM caschd, camast WHERE caschd.camastid=camast.camastid
                                                         AND caschd.deltd='N' AND catype IN ('017','020','023')) schd,
            afmast af
      WHERE NOT EXISTS (SELECT * FROM SEMAST WHERE ACCTNO=SCHD.AFACCTNO||SCHD.CODEID)
      AND af.acctno=schd.afacctno) SEMAST,
SBSECURITIES SYM,
(SELECT * FROM afmast
          WHERE custid NOT IN (SELECT distinct(custid) custid FROM afmast WHERE status NOT IN ('N','C'))) AF,
AFTYPE TYP, CFMAST CF,CIMAST CI, ALLCODE A1,ALLCODE A2, --FEEMASTER FT, FEEMAP FM,
(SELECT * FROM SENDSETOCLOSE where deltd='N') SENDSETOCLOSE,
(SELECT max(codeid)codeid,max(afacctno) afacctno,max(ISDBSEALL) ISDBSEALL,max(schd.seacctno)seacctno,
SUM(RIGHTOFFQTTY) RIGHTOFFQTTY,SUM(CAQTTYRECEIV) CAQTTYRECEIV,
SUM(CAQTTYDB) CAQTTYDB,SUM(CAAMTRECEIV) CAAMTRECEIV,SUM(RIGHTQTTY) RIGHTQTTY,
SUM(CASE WHEN ISWFT='N' THEN CAQTTYRECEIV ELSE 0 END ) CARECEIVING,
-- PhuongHT add them cho quyen moi lam den 3375
SUM(RIGHTOFFQTTY_PENDING) RIGHTOFFQTTY_PENDING,SUM(CAQTTYRECEIV_PENDING) CAQTTYRECEIV_PENDING,
SUM(CAAMTRECEIV_PENDING) CAAMTRECEIV_PENDING,SUM(RIGHTQTTY_PENDING) RIGHTQTTY_PENDING
FROM
(SELECT
    schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
   (CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C') AND schd.duedate >=GETCURRDATE )
      THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY,
   (CASE WHEN (schd.catype='014' AND schd.castatus  IN ('A','P','N'))
      THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY_PENDING,-- PhuongHT add them cho quyen moi lam den 3375
   (CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N' ) THEN schd.qtty
       WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W') AND isse='N' AND istocodeid='Y' ) THEN schd.qtty
       WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN schd.qtty
       ELSE 0 END) CAQTTYRECEIV,
    (CASE WHEN (schd.catype IN ('017','020','023') AND schd.status  IN ('A','P','N') AND isse='N' AND istocodeid='Y' ) THEN schd.qtty
          WHEN (schd.catype IN ('011','021') AND schd.status IN  ('A','P','N') AND isse='N' ) THEN schd.qtty
     ELSE 0 END) CAQTTYRECEIV_PENDING,-- PhuongHT add them cho quyen moi lam den 3375
   (CASE WHEN (schd.catype IN ('017','020','023') AND schd.status NOT IN ('G','S','I','O','W') AND isse='N') THEN schd.aqtty
         ELSE 0 END) CAQTTYDB,
   (CASE  WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W')) AND isse='N' THEN 1 ELSE 0 END) ISDBSEALL,
   (CASE WHEN  (schd.status  IN ('H','S','I','W')AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
        WHEN  SCHD.STATUS = 'K' AND SCHD.sendamt=0 THEN SCHD.AMT*(1-SCHD.EXERATE/100)
   ELSE 0 END) CAAMTRECEIV,
   (CASE WHEN  (schd.status   IN ('A','P','N') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
   ELSE 0 END) CAAMTRECEIV_PENDING,-- PhuongHT add them cho quyen moi lam den 3375
   (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W') AND isse='N') THEN schd.rqtty ELSE 0 END) RIGHTQTTY,
   (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status  IN ('A','P','N') ) THEN schd.rqtty ELSE 0 END) RIGHTQTTY_PENDING,-- PhuongHT add them cho quyen moi lam den 3375
  iswft

    FROM
          (SELECT schd.rqtty,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
           camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
           schd.isci,schd.isexec ,'N' istocodeid,NVL(ISWFT,'Y') ISWFT,schd.isse,CAMAST.EXERATE,sendamt
           FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
           UNION ALL
           SELECT schd.rqtty, schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
           '',schd.camastid,0,schd.qtty,0,0,0,0,0,
            schd.isci,schd.isexec ,'Y' istocodeid, NVL(ISWFT,'Y') ISWFT,schd.isse,CAMAST.EXERATE,sendamt
           FROM caschd schd, camast
           WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023') AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
           ) SCHD
         ) schd GROUP BY (codeid, afacctno) ) schd
WHERE A1.CDTYPE = 'SA' AND A1.CDNAME = 'TRADEPLACE' AND A1.CDVAL = SYM.TRADEPLACE
and A2.CDTYPE = 'CF' AND A2.CDNAME = 'DESTTYPE' AND A2.CDVAL = SENDSETOCLOSE.desttype
AND CF.CUSTID =AF.CUSTID AND SYM.CODEID = SEMAST.CODEID AND SEMAST.AFACCTNO= AF.ACCTNO and sym.sectype <> '004'
AND TYP.ACTYPE=AF.ACTYPE AND AF.status ='N'
--and ft.feecd = fm.feecd and ft.status = 'Y' and fm.tltxcd = '2247'
and AF.ACCTNO = CI.AFACCTNO
and (abs(semast.netting)+semast.deposit+semast.senddeposit+semast.receiving- nvl(schd.CARECEIVING,0)  )=0
and (semast.trade + semast.mortage +semast.blocked+ semast.withdraw+
nvl(SCHD.RIGHTQTTY,0) +nvl(SCHD.CAQTTYRECEIV,0)+nvl(SCHD.RIGHTOFFQTTY,0)+
NVL((CASE WHEN SCHD.ISDBSEALL=1 THEN SEMAST.TRADE ELSE SCHD.CAQTTYDB END),0)+
nvl(schd.CAAMTRECEIV,0)+
nvl(SCHD.RIGHTQTTY_PENDING,0) +nvl(SCHD.CAQTTYRECEIV_PENDING,0)+nvl(SCHD.RIGHTOFFQTTY_PENDING,0)+nvl(schd.CAAMTRECEIV_PENDING,0)) >0
and af.CUSTID=sendsetoclose.CUSTID(+)
AND semast.acctno=schd.seacctno(+) )
/
