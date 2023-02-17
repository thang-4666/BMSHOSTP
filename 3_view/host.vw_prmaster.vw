SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_PRMASTER
(PRCODE, PRNAME, PRTYPE, SYMBOL, PRSTATUS, 
 PRLIMIT, PRINUSED, PRINUSEDBOD, PRSECURED, PRAVLLIMIT, 
 EXPIREDDT, AFACCTNO, POOLTYPE, PRSECUREDCR, PRSECUREDDR, 
 POOLTYPEVAL, APPRV_STS, STATUS)
BEQUEATH DEFINER
AS 
SELECT MST.PRCODE, MST.PRNAME, A0.CDCONTENT PRTYPE, SB.SYMBOL, A1.CDCONTENT PRSTATUS, MST.PRLIMIT,
        NVL(MST.PRINUSED,0) + NVL(prlog.prinused,0) PRINUSED,
        (NVL(MST.PRINUSED,0) + (case when mst.pooltype='SY' then nvl(afpool.afpoolused,0) else 0 end))+
        GREATEST(NVL(tran.amt,0),0) PRINUSEDBOD,
        GREATEST(NVL(prlog.prinused,0),0) PRSECURED,
        GREATEST(MST.PRLIMIT - NVL(MST.PRINUSED,0) - GREATEST(NVL(prlog.prinused,0),0)
                             - (case when mst.pooltype='SY' then nvl(afpool.afpoolused,0) else 0 end)
                 ,0) PRAVLLIMIT,
        MST.EXPIREDDT,
        mst.afacctno,a2.cdcontent POOLTYPE,

        NVL(PR_EX.PRINUSED,0) PRSECUREDCR,
        GREATEST(NVL(tran.amt,0),0) PRSECUREDDR,
        MST.POOLTYPE POOLTYPEVAL,
        MST.APPRV_STS,MST.STATUS

FROM PRMASTER MST,
(SELECT CODEID, SYMBOL FROM SBSECURITIES UNION ALL SELECT CCYCD CODEID, SHORTCD SYMBOL FROM SBCURRENCY) SB,
ALLCODE A0, ALLCODE A1,
(select prcode, sum(prinused) prinused from prinusedlog where deltd <> 'Y' group by prcode) prlog,
(select prcode, sum(prinused) prinusedcr from prinusedlog where deltd <> 'Y' and prinused >0 group by prcode) prlogcr,
(select prcode, sum(prinused) prinuseddr from prinusedlog where deltd <> 'Y' and prinused <0 group by prcode) prlogdr,
(select sum(namt) amt, acctno prcode from prtran where txcd='0003' and deltd <> 'Y' and fn_check_after_batch<>1 group by  acctno) tran,
 (SELECT SUM(prlimit) afpoolused  from prmaster WHERE pooltype IN ('AF','GR') AND prstatus='A' ) afpool,
allcode a2,
(  SELECT SUM(LEAST(
              GREATEST( NVL(LOG.PRINUSED,0)-NVL(LOG_BUY.PRINUSED,0)+ LEAST(NVL(LOG_BUY.PRINUSED,0),NVL(VW.execbuyamt,0)),0)
              ,greatest(NVL(VW.execbuyamt,0)-greatest(nvl(ci.balance,0),0),0)
              )
             ) PRINUSED,LOG.PRCODE
 FROM
    (SELECT NVL(SUM(PRINUSED),0) PRINUSED,PRCODE,AFACCTNO FROM PRINUSEDLOG GROUP BY AFACCTNO,PRCODE) LOG,
    (SELECT NVL(SUM(PRINUSED),0) PRINUSED,AFACCTNO,PRCODE FROM PRINUSEDLOG LOG, TLLOG TL
    WHERE LOG.TXNUM=TL.TXNUM AND LOG.TXDATE=TL.TXDATE
    AND TL.TLTXCD IN ('8876','8884','8890','8882')
    GROUP BY AFACCTNO,PRCODE) LOG_BUY,
    V_GETBUYORDERINFO VW, cimast ci
 WHERE LOG.PRCODE=LOG_BUY.PRCODE(+)
       AND LOG.AFACCTNO=LOG_BUY.AFACCTNO(+)
       AND LOG.AFACCTNO=VW.AFACCTNO(+)
       and log.afacctno=ci.acctno
 GROUP BY LOG.PRCODE
  )
 PR_EX
WHERE MST.CODEID=SB.CODEID(+) AND A0.CDTYPE='SY'
     AND A0.CDNAME='PRTYPE' AND A0.CDVAL=MST.PRTYP
     AND A1.CDTYPE='SY' AND A1.CDNAME='PRSTATUS' AND A1.CDVAL=MST.PRSTATUS
     AND A2.CDTYPE='SA' AND A2.CDNAME='POOLTYPE' AND A2.CDVAL=MST.POOLTYPE
     and mst.prcode = prlog.prcode(+)
     and mst.prcode = prlogcr.prcode(+)
     and mst.prcode = prlogdr.prcode(+)
     and mst.prcode=tran.prcode(+)
     AND MST.PRCODE=PR_EX.PRCODE(+)
/
