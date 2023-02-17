SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0007 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
     )
IS
-- BAO CAO CHI TIET PHI LUU KY, TOAN CONG TY
-- CREATED BY ----DATE-----
-- THANHNM --  05/03/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
                -- USED WHEN V_NUMOPTION > 0
   V_FRDATE               DATE;
   V_TODATE               DATE;
   CUR            PKG_REPORT.REF_CURSOR;
   V_BE_CP_CCQ           NUMBER;
   V_BE_TP               NUMBER;

   V_STRCUSTODYCD       varchar2(20);
   V_STRNAME            varchar2(500);
BEGIN
   V_STROPTION := OPT;
   V_FRDATE := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE   := TO_DATE(T_DATE,'DD/MM/RRRR');
   V_STRCUSTODYCD := upper(PV_CUSTODYCD);

--LAY SO DU DAU KY CP
OPEN CUR
 FOR
   SELECT  NVL(SE.BAL - DTL.AMT,0)  BE_BALANCE
          FROM
               (SELECT SUM(SE.TRADE + SE.BLOCKED + SE.WITHDRAW + SE.MORTAGE
                + SE.SECURED + SE.NETTING + SE.DTOCLOSE + SE.WTRADE) BAL
                FROM CFMAST CF,SEMAST SE, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
                from    sbsecurities sb, sbsecurities sb1
                where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                    and cf.custodycd = V_STRCUSTODYCD
                AND SE.CODEID= SB.CODEID AND  SB.SECTYPE
                NOT IN ('004','003','006')
                 ) SE,
                (SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                   WHEN se.TXTYPE = 'C' THEN se.NAMT
                                   ELSE 0   END )),0) AMT
                FROM  CFMAST CF,VW_SETRAN_GEN   se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE
                    SE.DELTD <>'Y' and cf.custodycd = V_STRCUSTODYCD
                    AND  CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                    AND SE.NAMT <> 0
                    AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                    AND  SE.BUSDATE  >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                    AND  SE.CODEID=SB.CODEID
                    and  LENGTH(SE.acctno) >10
                    AND  SB.SECTYPE NOT IN ('004','003','006') --CP,CCQ
                    ) DTL
   ;

LOOP
  FETCH CUR
       INTO V_BE_CP_CCQ ;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
CLOSE CUR;

--TP
OPEN CUR
 FOR
   SELECT  NVL(SE.BAL - DTL.AMT,0)  BE_BALANCE
          FROM
               (SELECT SUM(SE.TRADE + SE.BLOCKED + SE.WITHDRAW + SE.MORTAGE + SE.SECURED + SE.NETTING + SE.DTOCLOSE + SE.WTRADE ) BAL
                FROM CFMAST CF,SEMAST SE, (
               select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE SE.CODEID= SB.CODEID and cf.custodycd = V_STRCUSTODYCD
                AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                AND SB.SECTYPE IN ('006','003')
                ) SE,
                (SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                   WHEN se.TXTYPE = 'C' THEN se.NAMT
                                   ELSE 0   END )),0) AMT
                FROM CFMAST CF,VW_SETRAN_GEN  se, (
                select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE
                    SE.DELTD <>'Y' and cf.custodycd = V_STRCUSTODYCD
                    AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                    AND SE.NAMT <> 0
                    AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                    AND  SE.BUSDATE  >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                    and  LENGTH(SE.acctno) >10
                    AND  SE.CODEID=SB.CODEID
                    AND SB.SECTYPE  IN ('006','003') --CP,CCQ
          ) DTL
   ;
LOOP
  FETCH CUR
       INTO V_BE_TP ;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
CLOSE CUR;

select max(fullname) into V_STRNAME from cfmast where custodycd = V_STRCUSTODYCD;
/*
if F_DATE= T_DATE then
--GET REPORT DATA
OPEN PV_REFCURSOR
FOR
    SELECT V_STRCUSTODYCD STRCUSTODYCD, V_STRNAME STRNAME, F_D,T_D,BE_CP_BAL,BE_TP_BAL, BE_CP_BAL + AMT_CP_BAL  F_CP,
    BE_TP_BAL+ AMT_TP_BAL F_TP,
    TRUNC((BE_CP_BAL + AMT_CP_BAL)*(1)* 0.5/30 +
    (BE_TP_BAL + AMT_TP_BAL)*(1)* 0.2/30 ) F_FEE
    FROM (
    SELECT TO_DATE (F_DATE  ,'DD/MM/YYYY') F_D, TO_DATE (T_DATE  ,'DD/MM/YYYY') T_D ,
    V_BE_CP_CCQ BE_CP_BAL, V_BE_TP BE_TP_BAL,
    FN_GET_SEBAL ('Y',TO_DATE (F_DATE  ,'DD/MM/YYYY'),TO_DATE (T_DATE  ,'DD/MM/YYYY'),'%',V_STRCUSTODYCD) AMT_CP_BAL,
    FN_GET_SEBAL ('N',TO_DATE (F_DATE  ,'DD/MM/YYYY'),TO_DATE (T_DATE  ,'DD/MM/YYYY'),'%',V_STRCUSTODYCD) AMT_TP_BAL
    from dual);

else
*/
--GET REPORT DATA
OPEN PV_REFCURSOR
FOR
    /*
    SELECT V_STRCUSTODYCD STRCUSTODYCD, V_STRNAME STRNAME, F_D,T_D, BE_CP_BAL, BE_TP_BAL, BE_CP_BAL + AMT_CP_BAL  F_CP,
    BE_TP_BAL+ AMT_TP_BAL F_TP,
    TRUNC((BE_CP_BAL + AMT_CP_BAL)*(T_D - F_D)* 0.5/30 +
    (BE_TP_BAL + AMT_TP_BAL)*( T_D - F_D)* 0.2/30 ) F_FEE
    FROM (
    SELECT SB1.SBDATE F_D, SB2.SBDATE T_D , V_BE_CP_CCQ BE_CP_BAL, V_BE_TP BE_TP_BAL,
    FN_GET_SEBAL ('Y',TO_DATE (F_DATE  ,'DD/MM/YYYY'),SB2.SBDATE,'%',V_STRCUSTODYCD) AMT_CP_BAL,
    FN_GET_SEBAL ('N',TO_DATE (F_DATE  ,'DD/MM/YYYY'),SB2.SBDATE,'%',V_STRCUSTODYCD) AMT_TP_BAL
    FROM
    (select * from SBCLDR sb1 where SB1.CLDRTYPE='000' and  SB1.SBDATE >= TO_DATE (F_DATE  ,'DD/MM/YYYY') AND SB1.SBDATE <= TO_DATE (T_DATE  ,'DD/MM/YYYY')) SB1,
    (select * from SBCLDR sb2 where SB2.CLDRTYPE='000' and SB2.SBDATE >= TO_DATE (F_DATE  ,'DD/MM/YYYY') AND SB2.SBDATE <= TO_DATE (T_DATE  ,'DD/MM/YYYY') +1) SB2
    WHERE
     SB2.SBDATE = SB1.SBDATE +1
    );
    */
    select cf.custodycd STRCUSTODYCD, cf.fullname STRNAME, sedp.txdate F_D,
        getduedate(sedp.txdate, 'N', '000', sedp.days) T_D,
        V_BE_CP_CCQ BE_CP_BAL, V_BE_TP BE_TP_BAL,
        sum(case when sb1.sectype NOT IN ('006','003') then case when sedp.amt =0 then 0 else  sedp.qtty end  else 0 end) F_CP,
        sum(case when sb1.sectype IN ('006','003') then case when sedp.amt =0 then 0 else  sedp.qtty end else 0 end) F_TP,
        sum(sedp.amt) F_FEE
    From sedepobal sedp, semast se, sbsecurities sb1,
        afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    where sedp.acctno = se.acctno
        and se.afacctno = af.acctno
        and af.custid = cf.custid
        and se.codeid = sb1.codeid
        and sedp.deltd <> 'Y'
        and sb1.sectype <> '004'
        and cf.custodycd = V_STRCUSTODYCD
        and sedp.txdate  >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
        and sedp.txdate  <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
----        and getduedate(sedp.txdate, 'N', '000', sedp.days) <= TO_DATE (T_DATE,'DD/MM/YYYY')
    group by cf.custodycd, cf.fullname, sedp.txdate ,
        getduedate(sedp.txdate, 'N', '000', sedp.days)
    having sum(case when sb1.sectype NOT IN ('006','003') then  sedp.qtty else 0 end) <> 0 or
        sum(case when sb1.sectype IN ('006','003') then sedp.qtty else 0 end) <> 0 or
        sum(sedp.amt) <> 0
    order by sedp.txdate
    ;
---end if;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
