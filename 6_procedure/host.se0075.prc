SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0075" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2
     )
IS
-- BAO CAO CHI TIET PHI LUU KY, TOAN CONG TY
-- CREATED BY ----DATE-----
-- THANHNM --  05/03/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_FRDATE               DATE;
   V_TODATE               DATE;
   CUR            PKG_REPORT.REF_CURSOR;
   V_BE_CP_CCQ           NUMBER;
   V_BE_TP               NUMBER;
   V_STRBRNAME    VARCHAR2(500);
BEGIN
   V_STROPTION := OPT;
   V_FRDATE := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE   := TO_DATE(T_DATE,'DD/MM/RRRR');

IF I_BRID = 'ALL' THEN
    V_STRBRID := '%%';
    V_STRBRNAME:='all';
ELSE
    IF I_BRID = 'GROUP1' THEN
        V_STRBRID:='00__';
        --GET BARANCH NAME

        FOR REC IN (SELECT * FROM BRGRP WHERE SUBSTR(BRID,1,2)='00')
        LOOP
            V_STRBRNAME:= V_STRBRNAME||REC.BRNAME||',';
        END LOOP;
        V_STRBRNAME := SUBSTR(V_STRBRNAME,1,LENGTH(V_STRBRNAME) -1);
    ELSE
        IF  I_BRID = 'GROUP2' THEN
        V_STRBRID:='01__';
        FOR REC IN (SELECT * FROM BRGRP WHERE SUBSTR(BRID,1,2)='01')
        LOOP
            V_STRBRNAME:= V_STRBRNAME||REC.BRNAME||',';
        END LOOP;
        V_STRBRNAME := SUBSTR(V_STRBRNAME,1,LENGTH(V_STRBRNAME) -1);
        ELSE
        V_STRBRID:=I_BRID;
        FOR REC IN (SELECT * FROM BRGRP WHERE BRID = V_STRBRID )
        LOOP
            V_STRBRNAME:= V_STRBRNAME||REC.BRNAME||',';
        END LOOP;
         V_STRBRNAME := SUBSTR(V_STRBRNAME,1,LENGTH(V_STRBRNAME) -1);
         END IF;
      END IF;
END IF;

--LAY SO DU DAU KY CP
OPEN CUR
 FOR
   SELECT  NVL(SE.BAL - DTL.AMT,0)  BE_BALANCE
          FROM
               (SELECT SUM(SE.TRADE + SE.BLOCKED + SE.WITHDRAW + SE.MORTAGE
                + SE.SECURED + SE.NETTING + SE.DTOCLOSE + SE.WTRADE
                + nvl(se.blockwithdraw,0) + nvl(se.blockdtoclose,0) + nvl(se.emkqtty,0)) BAL
                FROM CFMAST CF,SEMAST SE, AFMAST AF, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
                from    sbsecurities sb, sbsecurities sb1
                where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE
                CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                AND SE.AFACCTNO = AF.ACCTNO AND AF.ACTYPE NOT IN '0000'
                AND SE.CODEID= SB.CODEID AND  SB.SECTYPE
                NOT IN ('004','003','006')
                 AND substr( se.CUSTID, 1,4) LIKE V_STRBRID) SE,
                (SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                   WHEN se.TXTYPE = 'C' THEN se.NAMT
                                   ELSE 0   END )),0) AMT
                FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,VW_SETRAN_GEN   se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE
                    SE.DELTD <>'Y'
                    AND  CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                    AND SE.NAMT <> 0
                    AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE','BLOCKWITHDRAW','BLOCKDTOCLOSE','EMKQTTY')
                    AND  SE.BUSDATE  >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                    AND  SE.CODEID=SB.CODEID
                    and  LENGTH(SE.acctno) >10
                    AND  SB.SECTYPE NOT IN ('004','003','006') --CP,CCQ
                    AND substr( se.CUSTID, 1,4) LIKE V_STRBRID
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
               (SELECT SUM(SE.TRADE + SE.BLOCKED + SE.WITHDRAW + SE.MORTAGE + SE.SECURED + SE.NETTING + SE.DTOCLOSE + SE.WTRADE
                        + nvl(se.blockwithdraw,0) + nvl(se.blockdtoclose,0) + nvl(se.emkqtty,0)) BAL
                FROM CFMAST CF,SEMAST SE, AFMAST AF,  (
               select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE SE.CODEID= SB.CODEID
                AND SE.AFACCTNO = AF.ACCTNO AND AF.ACTYPE NOT IN '0000'
                AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                AND SB.SECTYPE IN ('006','003')
                AND substr( se.CUSTID, 1,4) LIKE V_STRBRID ) SE,
                (SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                   WHEN se.TXTYPE = 'C' THEN se.NAMT
                                   ELSE 0   END )),0) AMT
                FROM CFMAST CF,VW_SETRAN_GEN  se, (
                select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                WHERE
                    SE.DELTD <>'Y'
                    AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                    AND SE.NAMT <> 0
                    AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE','BLOCKWITHDRAW','BLOCKDTOCLOSE','EMKQTTY')
                    AND  SE.BUSDATE  >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                    and  LENGTH(SE.acctno) >10
                    AND  SE.CODEID=SB.CODEID
                    AND SB.SECTYPE  IN ('006','003') --CP,CCQ
                    AND substr(se.CUSTID, 1,4) LIKE V_STRBRID
          ) DTL

   ;

LOOP
  FETCH CUR
       INTO V_BE_TP ;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
CLOSE CUR;


if F_DATE= T_DATE then
--GET REPORT DATA
OPEN PV_REFCURSOR
FOR
    SELECT '[' || I_BRID || ']' || V_STRBRNAME  F_BRNAME,F_D,T_D,BE_CP_BAL,BE_TP_BAL,BE_CP_BAL + AMT_CP_BAL  F_CP,
    BE_TP_BAL+ AMT_TP_BAL F_TP,
    TRUNC((BE_CP_BAL + AMT_CP_BAL)*(1)* 0.4/30 +
    (BE_TP_BAL + AMT_TP_BAL)*(1)* 0.2/30 ) F_FEE
    FROM (
    SELECT TO_DATE (F_DATE  ,'DD/MM/YYYY') F_D, TO_DATE (T_DATE  ,'DD/MM/YYYY') T_D ,
    V_BE_CP_CCQ BE_CP_BAL, V_BE_TP BE_TP_BAL,
    FN_GET_SEBAL ('Y',TO_DATE (F_DATE  ,'DD/MM/YYYY'),TO_DATE (T_DATE  ,'DD/MM/YYYY'),V_STRBRID,'ALL') AMT_CP_BAL,
    FN_GET_SEBAL ('N',TO_DATE (F_DATE  ,'DD/MM/YYYY'),TO_DATE (T_DATE  ,'DD/MM/YYYY'),V_STRBRID,'ALL') AMT_TP_BAL

    from dual);

else
--GET REPORT DATA
OPEN PV_REFCURSOR
FOR

    SELECT '[' || I_BRID || ']' || V_STRBRNAME  F_BRNAME,F_D,T_D,BE_CP_BAL,BE_TP_BAL,BE_CP_BAL + AMT_CP_BAL  F_CP,
    BE_TP_BAL+ AMT_TP_BAL F_TP,
    TRUNC((BE_CP_BAL + AMT_CP_BAL)*(T_D - F_D)* 0.4/30 +
    (BE_TP_BAL + AMT_TP_BAL)*( T_D - F_D)* 0.2/30 ) F_FEE
    FROM (
    SELECT SB1.SBDATE F_D, SB2.SBDATE T_D , V_BE_CP_CCQ BE_CP_BAL, V_BE_TP BE_TP_BAL,
    --FN_GET_SEBAL ('Y',SB1.SBDATE,SB2.SBDATE) AMT_CP_BAL,
    --FN_GET_SEBAL ('N',SB1.SBDATE,SB2.SBDATE) AMT_TP_BAL
    FN_GET_SEBAL ('Y',TO_DATE (F_DATE  ,'DD/MM/YYYY'),SB2.SBDATE,V_STRBRID,'ALL') AMT_CP_BAL,
    FN_GET_SEBAL ('N',TO_DATE (F_DATE  ,'DD/MM/YYYY'),SB2.SBDATE,V_STRBRID,'ALL') AMT_TP_BAL
    FROM
    (select * from SBCLDR sb1 where SB1.CLDRTYPE='000' and  SB1.SBDATE >= TO_DATE (F_DATE  ,'DD/MM/YYYY') AND SB1.SBDATE <= TO_DATE (T_DATE  ,'DD/MM/YYYY')) SB1,
    (select * from SBCLDR sb2 where SB2.CLDRTYPE='000' and SB2.SBDATE >= TO_DATE (F_DATE  ,'DD/MM/YYYY') AND SB2.SBDATE <= TO_DATE (T_DATE  ,'DD/MM/YYYY') +1) SB2
    WHERE
     SB2.SBDATE = SB1.SBDATE +1
    --ORDER BY SB1.SBDATE
    );

end if;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
