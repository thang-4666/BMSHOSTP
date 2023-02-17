SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0011" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2, -- MA chung khoan
   PV_TRADEPLACE  IN       VARCHAR2
   )
IS
--
-- RePort NAME: Bao cao ve hoat dong luu ky chung khoan
-- Person : quyet.kieu
-- Date : 22/03/2011
-----------------------------------------------

V_SYMBOL   VARCHAR2 (20);
 vn_TRADEPLACE varchar2(50);
   v_strTRADEPLACE VARCHAR2 (4);

BEGIN
V_SYMBOL :=  SYMBOL;

   IF (SYMBOL <> 'ALL')
   THEN
     V_SYMBOL :=  SYMBOL;
   ELSE
     V_SYMBOL :=  '%%' ;
   END IF;


IF  (upper(PV_TRADEPLACE) <> 'ALL')
THEN
      v_strTRADEPLACE := upper(PV_TRADEPLACE);
      SELECT cdcontent INTO vn_TRADEPLACE FROM allcode WHERE cdtype = 'SE' AND cdname = 'TRADEPLACE' AND cdval like PV_TRADEPLACE ;
ELSE
   v_strTRADEPLACE := '%';
   vn_TRADEPLACE := 'ALL';
END IF;


-- GET REPORT'S PARAMETERS
    OPEN PV_REFCURSOR FOR
SELECT SB.* FROM (
SELECT  max(CASE WHEN SB.SECTYPE = '001' THEN ' I. CỔ PHIẾU '
            WHEN SB.SECTYPE in ('006','003') THEN ' II. TRÁI PHIẾU '
            WHEN SB.SECTYPE = '008' THEN ' III. CHỨNG CHỈ QUỸ ' END) GR_I,
        max(CASE WHEN SB.TRADEPLACE = '001' THEN ' 2. Niêm yết tại sán HOSE '
            WHEN SB.TRADEPLACE = '002' THEN ' 1. Niêm yết tại sán HNX '
                        when sb.tradeplace ='005' then ' 3. UPCOM '
            ELSE ' 4. WFT ' END) GR_II,
        I_DATE i_date,
        sb.tradeplace,
        sb.symbol,SB.CODEID,
        sum(decode(CF.COUNTRY,'234', num.amt,0)) KL_VN  ,
        Sum(decode(CF.COUNTRY,'234', 0,num.amt)) KL_NN  ,
        sum(num.amt) KL_ALL,
        se.listingqtty KL_Niemyet

FROM    afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,securities_info se ,
    (
        select  SB.TRADEPLACE TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
        from    sbsecurities sb, sbsecurities sb1
        where   nvl(sb.refcodeid,' ') = sb1.codeid(+) and nvl(sb1.symbol,sb.symbol) like V_SYMBOL
    ) SB,
    ALLCODE AL,
    (
        SELECT  SE.ACCTNO ,
        (SE.TRADE + SE.BLOCKED + SE.EMKQTTY + se.secured + SE.BLOCKWITHDRAW + SE.WITHDRAW + SE.MORTAGE +NVL(SE.netting,0) +
            NVL(SE.blockdtoclose,0) + NVL(SE.dtoclose,0) - NVL(NUM.AMT,0) + SE.WTRADE) AMT
        FROM    SEMAST SE
    LEFT JOIN
    (
        SELECT  NVL(SUM(AMT ),0) AMT, ACCTNO
        FROM
        (
            select SUM ((CASE WHEN tr.TXTYPE = 'D'THEN -TR.NAMT WHEN
                    tr.TXTYPE = 'C' THEN TR.NAMT ELSE 0 END )) AMT, TR.ACCTNO ACCTNO
            from VW_SETRAN_GEN tr
            where tr.txtype in ('D','C')
                and tr.namt <> 0
                and tr.busdate > to_date(I_DATE,'DD/MM/YYYY')
                and tr.FIELD IN ('TRADE','EMKQTTY','BLOCKED','WITHDRAW','BLOCKWITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','BLOCKDTOCLOSE','WTRADE')
                and tr.DELTD <> 'Y'
            GROUP BY  TR.ACCTNO
          ) GROUP BY ACCTNO
    ) NUM ON NUM.ACCTNO =SE.ACCTNO
WHERE (SE.TRADE + SE.BLOCKED + se.secured + SE.WITHDRAW + SE.MORTAGE + NVL(SE.netting,0) + NVL(SE.dtoclose,0) - NVL(NUM.AMT,0) + NVL(SE.WTRADE,0))<>0
) NUM
WHERE   SUBSTR(NUM.ACCTNO,1,10) = AF.ACCTNO
    AND AF.CUSTID = CF.CUSTID
    AND CF.CUSTATCOM='Y'
    AND SUBSTR(NUM.ACCTNO,11,6) = SB.CODEID
    and Se.codeid = sb.codeid
    and sb.symbol like V_SYMBOL
    AND AL.CDNAME = 'COUNTRY'
    AND AL.CDTYPE = 'CF'
    AND AL.CDVAL = CF.COUNTRY
    AND sb.SECTYPE NOT IN ('004')
group by sb.tradeplace, sb.symbol,SB.CODEID, se.listingqtty

) sb , setradeplace setr

       where sb.codeid = setr.codeid (+)

       and case when nvl(setr.codeid,'xxx') = sb.codeid and setr.txdate > to_date(I_DATE,'DD/MM/YYYY') then setr.frtradeplace
                else sb.TRADEPLACE  end like v_strTRADEPLACE

ORDER BY sb.symbol

;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
