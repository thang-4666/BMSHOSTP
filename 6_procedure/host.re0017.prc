SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0017 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT             IN       VARCHAR2,
   pv_BRID         IN       VARCHAR2,
   TLGOUPS         IN       VARCHAR2,
   TLSCOPE         IN       VARCHAR2,
   I_DATE          IN       VARCHAR2,
   PV_CUSTODYCD    IN       VARCHAR2,
   RECUSTODYCD     IN       VARCHAR2

 )
IS

--BAO CAO CHI TIET TAI KHOAN KHACH HANG --VCBSDEPII-552
--NGOCVTT 30/08/2016
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

   V_CUSTODYCD  VARCHAR2(100);
   V_INDATE    DATE;
   V_CURRDATE   DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_STRCUSTODYCD    VARCHAR2(100);
   V_NHOM   VARCHAR2(100);
BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS


    IF RECUSTODYCD = 'ALL' OR RECUSTODYCD IS NULL THEN
        V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD := RECUSTODYCD;
    END IF;


    IF PV_CUSTODYCD = 'ALL' OR PV_CUSTODYCD IS NULL THEN
        V_STRCUSTODYCD := '%%';
    ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
    END IF;

   V_INDATE:=TO_DATE(I_DATE,'DD/MM/YYYY');
   
   SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO V_CURRDATE FROM SYSVAR
   WHERE VARNAME='CURRDATE';

     BEGIN
            SELECT MAX(TN.AUTOID) INTO V_NHOM
            FROM regrplnk nhom, regrp tn, reaflnk lnk
            WHERE tn.autoid = nhom.refrecflnkid 
                  AND  lnk.frdate <= V_INDATE
                  AND nvl(lnk.clstxdate,lnk.todate) > V_INDATE
                  AND SUBSTR(LNK.REACCTNO,1,10) LIKE V_CUSTODYCD
                  and lnk.refrecflnkid = nhom.autoid;
     EXCEPTION
     WHEN OTHERS
     THEN
           V_NHOM:='';
     END;  
   
   IF V_INDATE=V_CURRDATE THEN
     
      OPEN  PV_REFCURSOR FOR
        SELECT V_INDATE INDATE,V_CUSTODYCD RECUSTID, V_STRCUSTODYCD IN_CUSTODYCD,V_NHOM NHOM,
                 CF.CUSTODYCD, MAIN.PRODUCTTYPE, MAIN.CDCONTENT, MAIN.SYMBOL,TRADE,  MORTAGE,
                 CARECEIVING, WITHDRAW,  DTOCLOSE, ODRECEIVING,
                TOTAL, AMT,  CIRECEIVING,  MRAMT,MAIN.STT
          FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,  (
                    
                 select cf.CUSTODYCD,AF.PRODUCTTYPE,A.CDCONTENT, sb.SYMBOL, sum(se.trade) trade,
                         sum(se.mortage+se.STANDING) MORTAGE,
                          sum(se.RECEIVING-(nvl(sts.receiving,0) +nvl(BUYQTTY,0)- nvl(BUYINGQTTY,0))) careceiving, 
                          sum(se.WITHDRAW) WITHDRAW,sum(se.DTOCLOSE) DTOCLOSE,
                          sum(nvl(sts.receiving,0) + nvl(BUYQTTY,0) - nvl(BUYINGQTTY,0)) ODRECEIVING ,
                          sum(se.trade+nvl(sts.receiving,0) + nvl(BUYQTTY,0) - nvl(BUYINGQTTY,0)+ 
                          (se.RECEIVING-(nvl(sts.receiving,0) +nvl(BUYQTTY,0)- nvl(BUYINGQTTY,0)))+se.WITHDRAW  
                          + se.mortage+se.STANDING+se.DTOCLOSE-nvl(od.EXECQTTY,0)) TOTAL
                          , 0 AMT, 0 CIRECEIVING, 0 MRAMT,0 STT
                 from cfmast cf , allcode a, SBSECURITIES sb,afmast af,semast se
                   
                   left join
                    
                   (select sum(BUYQTTY) BUYQTTY, sum(BUYINGQTTY) BUYINGQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                                          from (
                                              SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                                                     (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY,
                                                     (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                                              FROM odmast od, afmast af,
                                                  (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                                                 where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                                                 and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                                                 AND od.deltd <> 'Y'
                                                 --AND od.errod = 'N'
                                                 and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                                                 AND od.exectype IN ('NS', 'MS','NB','BC')
                                              )
                                   group by AFACCTNO, CODEID
                   ) OD  on OD.afacctno =se.afacctno and OD.codeid =se.codeid
                  
                 left join
                  (SELECT STS.CODEID,STS.AFACCTNO,
                                          SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                                      FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                                      sysvar sy
                                      WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                                          and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                                          AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                                          GROUP BY STS.AFACCTNO,STS.CODEID
                    ) sts
                                  on sts.afacctno =se.afacctno and sts.codeid=se.codeid
                                  
                    where se.afacctno =af.acctno
                    and cf.custid=af.custid 
                    AND se.CODEID=SB.CODEID AND SB.SECTYPE<>'004'
                    AND A.CDTYPE='CF' AND A.CDNAME='PRODUCTTYPE' AND A.CDVAL=AF.PRODUCTTYPE     
                    and cf.CUSTODYCD LIKE V_STRCUSTODYCD
                    group by cf.CUSTODYCD,AF.PRODUCTTYPE,A.CDCONTENT, sb.SYMBOL
                    
                    UNION ALL

                      SELECT CUSTODYCD,PRODUCTTYPE,CDCONTENT,SYMBOL, 0 TRADE, 0 MORTAGE,
                            0 CARECEIVING,0 WITHDRAW,0 DTOCLOSE,0 ODRECEIVING,
                            0 TOTAL,SUM(AMT) AMT, SUM(CIRECEIVING) CIRECEIVING, SUM(MRAMT) MRAMT,1 STT
                      FROM(
                          SELECT LOG.CUSTODYCD,LOG.AFACCTNO,AF.PRODUCTTYPE,A.CDCONTENT, 'TM' SYMBOL,
                                 ROUND(LOG.intbalance) AMT, ROUND(LOG.AVLADVANCE) CIRECEIVING,ROUND(ODAMT) MRAMT
                          FROM BUF_CI_ACCOUNT LOG, AFMAST AF, ALLCODE A

                          WHERE LOG.AFACCTNO=AF.ACCTNO
                                AND A.CDTYPE='CF' AND A.CDNAME='PRODUCTTYPE' AND A.CDVAL=AF.PRODUCTTYPE
                                AND LOG.CUSTODYCD LIKE V_STRCUSTODYCD
                          )
                      GROUP BY CUSTODYCD,PRODUCTTYPE,CDCONTENT,SYMBOL
                 ) MAIN,
                 (SELECT  LNK.AFACCTNO ,max(CFRE.CUSTID) CUSTID
                           FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                           WHERE LNK.DELTD <> 'Y' --AND TYP.REROLE='CS'
                                AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                                AND  lnk.frdate <= V_CURRDATE
                                AND nvl(lnk.clstxdate,lnk.todate) > V_CURRDATE
                                AND NVL(CFRE.CUSTID,'000') LIKE V_CUSTODYCD
                                GROUP BY LNK.AFACCTNO ) RE
                  WHERE CF.CUSTID=RE.AFACCTNO
                        AND CF.CUSTODYCD=MAIN.CUSTODYCD
          ORDER BY MAIN.STT,MAIN.CUSTODYCD,  MAIN.SYMBOL;
   
ELSE
  
    OPEN  PV_REFCURSOR
     FOR
          SELECT V_INDATE INDATE,V_CUSTODYCD RECUSTID, V_STRCUSTODYCD IN_CUSTODYCD,V_NHOM NHOM,
                MAIN.CUSTODYCD, MAIN.PRODUCTTYPE, MAIN.CDCONTENT, MAIN.SYMBOL,TRADE,  MORTAGE,
                 CARECEIVING,  WITHDRAW,  DTOCLOSE,  ODRECEIVING,
                TOTAL, AMT,CIRECEIVING,  MRAMT,MAIN.STT
          FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,  
               (
               SELECT LOG.CUSTODYCD,AF.PRODUCTTYPE,A.CDCONTENT, LOG.SYMBOL, SUM(NVL(LOG.TRADE,0)) TRADE, SUM(LOG.MORTAGE_NAV) MORTAGE,
                            SUM(LOG.CARECEIVING) CARECEIVING,
                            SUM(LOG.WITHDRAW) WITHDRAW,SUM(LOG.DTOCLOSE) DTOCLOSE,SUM(LOG.ODRECEIVING) ODRECEIVING,
                            SUM(NVL(TRADE,0)+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY) TOTAL,
                            0 AMT, 0 CIRECEIVING, 0 MRAMT,0 STT
                      FROM TBL_MR3007_LOG LOG, AFMAST AF, ALLCODE A, SBSECURITIES SB

                      WHERE LOG.AFACCTNO=AF.ACCTNO AND LOG.CODEID=SB.CODEID AND SB.SECTYPE<>'004'
                            AND A.CDTYPE='CF' AND A.CDNAME='PRODUCTTYPE' AND A.CDVAL=AF.PRODUCTTYPE
                            AND LOG.CUSTODYCD LIKE V_STRCUSTODYCD AND LOG.TXDATE=V_INDATE
                            AND NVL(TRADE,0)+ODRECEIVING+ CARECEIVING+WITHDRAW+ MORTAGE_NAV+DTOCLOSE-EXECQTTY>0

                            GROUP BY  LOG.CUSTODYCD,AF.PRODUCTTYPE,A.CDCONTENT, LOG.SYMBOL 
                      UNION ALL

                      SELECT CUSTODYCD,PRODUCTTYPE,CDCONTENT,SYMBOL, 0 TRADE, 0 MORTAGE,
                            0 CARECEIVING,0 WITHDRAW,0 DTOCLOSE,0 ODRECEIVING,
                            0 TOTAL,SUM(AMT) AMT, SUM(CIRECEIVING) CIRECEIVING, SUM(MRAMT) MRAMT,1 STT
                      FROM(
                          SELECT LOG.CUSTODYCD,LOG.AFACCTNO,AF.PRODUCTTYPE,A.CDCONTENT, 'TM' SYMBOL,
                                 ROUND(MAX(LOG.BALANCE)) AMT, ROUND(MAX(LOG.AVLADVANCE)) CIRECEIVING,ROUND(MAX(MRAMT)) MRAMT
                          FROM TBL_MR3007_LOG LOG, AFMAST AF, ALLCODE A

                          WHERE LOG.AFACCTNO=AF.ACCTNO
                                AND A.CDTYPE='CF' AND A.CDNAME='PRODUCTTYPE' AND A.CDVAL=AF.PRODUCTTYPE
                                AND LOG.CUSTODYCD LIKE V_STRCUSTODYCD AND LOG.TXDATE=V_INDATE

                                GROUP BY  LOG.CUSTODYCD,LOG.AFACCTNO,AF.PRODUCTTYPE,A.CDCONTENT
                          )
                      GROUP BY CUSTODYCD,PRODUCTTYPE,CDCONTENT,SYMBOL
                 ) MAIN,
                 (SELECT  LNK.AFACCTNO ,max(CFRE.CUSTID) CUSTID
                           FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                           WHERE LNK.DELTD <> 'Y' 
                                AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                                AND  lnk.frdate <= V_INDATE
                                AND nvl(lnk.clstxdate,lnk.todate) > V_INDATE
                                AND NVL(CFRE.CUSTID,'000') = V_CUSTODYCD
                                GROUP BY LNK.AFACCTNO ) RE
                  WHERE CF.CUSTID=RE.AFACCTNO
                        AND CF.CUSTODYCD=MAIN.CUSTODYCD      
          ORDER BY MAIN.STT,MAIN.CUSTODYCD, MAIN.SYMBOL;

    END IF;
    
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
