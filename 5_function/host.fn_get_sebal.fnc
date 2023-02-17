SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_SEBAL(P_SECTYPE IN VARCHAR2,P_F_DATE IN DATE, P_T_DATE IN DATE, P_BRID IN VARCHAR2,P_custodycd IN VARCHAR2)
    RETURN NUMBER IS
-- PURPOSE: SO CK THAY DOI TRONG KY
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   09/03/2012     CREATED
   V_RESULT         NUMBER;
   V_STRCUSTODYCD   VARCHAR2(20);

BEGIN
V_RESULT :=0;
if(upper(P_custodycd) = 'ALL') then
V_STRCUSTODYCD := '%';
else
V_STRCUSTODYCD := P_custodycd;
end if;

IF P_SECTYPE ='Y' THEN -- CP, CCQ
    if P_F_DATE = P_T_DATE then
      SELECT NVL(SUM(A.AMT),0) INTO V_RESULT
                    FROM (
                    SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                       WHEN se.TXTYPE = 'C' THEN se.NAMT
                                       ELSE 0   END )),0) AMT
                    FROM CFMAST CF,VW_SETRAN_GEN se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                    WHERE
                        SE.DELTD <>'Y'
                        AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                        AND SE.NAMT <> 0
                        AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                        AND  SE.BUSDATE  = P_F_DATE
                        AND  SE.BUSDATE  = P_T_DATE
                        and  LENGTH(se.acctno) >10
                        AND  SE.CODEID=SB.CODEID
                        AND  SB.SECTYPE NOT IN ('006','004','003')
                        AND substr(se.CUSTID, 1,4) LIKE P_BRID
                        ) A WHERE A.AMT <>0;
    else
      SELECT NVL(SUM(A.AMT),0) INTO V_RESULT
                    FROM (
                    SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                       WHEN se.TXTYPE = 'C' THEN se.NAMT
                                       ELSE 0   END )),0) AMT
                    FROM CFMAST CF,VW_SETRAN_GEN se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)
        ) SB
        WHERE SE.DELTD <>'Y' and cf.custodycd like V_STRCUSTODYCD
                         AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                        AND SE.NAMT <> 0
                        AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                          AND  SE.BUSDATE  >= P_F_DATE
                        AND  SE.BUSDATE  < P_T_DATE
                        and  LENGTH(se.acctno) >10
                        AND  SE.CODEID=SB.CODEID
                        AND  SB.SECTYPE NOT IN ('006','004','003')
                        --AND  SB.TRADEPLACE   IN ('001', '002', '005')
                        AND substr(se.CUSTID, 1,4) LIKE P_BRID
                        ) A WHERE A.AMT <>0;
    end if;

ELSE --TP

    if P_F_DATE = P_T_DATE then
    SELECT NVL(SUM(A.AMT),0) INTO V_RESULT
                    FROM (
                    SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                       WHEN se.TXTYPE = 'C' THEN se.NAMT
                                       ELSE 0   END )),0) AMT
                    FROM CFMAST CF,VW_SETRAN_GEN se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                    WHERE SE.DELTD <>'Y' and cf.custodycd like V_STRCUSTODYCD
                         AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                        AND SE.NAMT <> 0
                        AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                        AND  SE.BUSDATE  = P_F_DATE
                        AND  SE.BUSDATE  = P_T_DATE
                        and  LENGTH(se.acctno) >10
                        AND  SE.CODEID=SB.CODEID
                        AND SB.SECTYPE IN ('006','003') --TP
                        --AND  SB.TRADEPLACE   IN ('001', '002', '005')
                        AND substr(se.CUSTID, 1,4) LIKE P_BRID
                     ) A WHERE A.AMT <>0;
    else
    SELECT NVL(SUM(A.AMT),0) INTO V_RESULT
                    FROM (
                    SELECT   NVL(SUM ((CASE WHEN se.TXTYPE = 'D'THEN -se.NAMT
                                       WHEN se.TXTYPE = 'C' THEN se.NAMT
                                       ELSE 0   END )),0) AMT
                    FROM CFMAST CF,VW_SETRAN_GEN se, (select  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+)) SB
                    WHERE
                        SE.DELTD <>'Y' and cf.custodycd like V_STRCUSTODYCD
                        AND CF.CUSTID = SE.CUSTID AND CF.CUSTATCOM ='Y'
                        AND SE.NAMT <> 0
                        AND TRIM (SE.FIELD) IN('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
                        AND  SE.BUSDATE  >= P_F_DATE
                        AND  SE.BUSDATE  < P_T_DATE
                        and  LENGTH(se.acctno) >10
                        AND  SE.CODEID=SB.CODEID
                        AND SB.SECTYPE IN ('006','003') --TP
                        --AND  SB.TRADEPLACE   IN ('001', '002', '005')
                        AND substr(se.CUSTID, 1,4) LIKE P_BRID
                     ) A WHERE A.AMT <>0;
    end if;

END IF;
RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;


                                                             -- PROCEDURE
 
 
 
 
 
 
 
 
 
 
 
/
