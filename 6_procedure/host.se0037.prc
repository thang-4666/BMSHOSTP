SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0037 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PLSENT         IN       VARCHAR2,
   HDNUM           IN      VARCHAR2
)
IS

-- RP NAME : YEU CAU CHUYEN KHOAN CAM CO CHUNG KHOAN 20A/LK
-- PERSON              DATE            COMMENTS
-- QUYET.KIEU          05/04/2011      CREATE
-- DIENNT              12/01/2012      EDIT
-- ---------   ------  -------------------------------------------
   V_SYMBOL  VARCHAR2 (20);
   V_CUSTODYCD VARCHAR2 (15);
   V_TRADEPLACE VARCHAR2 (15);

   V_STRPLSENT VARCHAR2 (100);
   V_STRHDNUM   VARCHAR2(100);
BEGIN
-- GET REPORT'S PARAMETERS


   IF  (TRADEPLACE <> 'ALL')
   THEN
         V_TRADEPLACE := TRADEPLACE;
   ELSE
        V_TRADEPLACE := '%';
   END IF;


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_SYMBOL <> 'ALL')
   THEN
         V_SYMBOL := PV_SYMBOL;
   ELSE
      V_SYMBOL := '%';
   END IF;

   V_STRPLSENT := PLSENT;

      IF  (HDNUM <> 'ALL')
   THEN
         V_STRHDNUM := HDNUM;
   ELSE
      V_STRHDNUM := '%';
   END IF;


-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
Select V_STRPLSENT PLSENT ,V_STRHDNUM HDNUM,SE.CVALUE, (case
         when sb.tradeplace='002' then '1. HNX'
          when sb.tradeplace='001' then '2. HOSE'
          when sb.tradeplace='005' then '3. UPCOM'
          when sb.tradeplace='007' then '4. TRAI PHIEU CHUYEN BIET'
          when sb.tradeplace='008' then '6. TIN PHIEU'
          when sb.tradeplace='009' then '7. ?CNY'
          else '' end) san,
          se.Codeid ,
          REPLACE(sb.symbol,'_WFT','') symbol,
          nvl(sb.Parvalue,0) Parvalue ,
          sum(nvl(se.msgamt,0)) msgamt,
          (  sum(nvl(se.msgamt,0)) * nvl(sb.Parvalue,0)) Gia_tri,
          (case when substr(cf.custodycd,4,1)='F' then '01213.086'
                when substr(cf.custodycd,4,1)='P' then '01211.086'
                else '01212.086' end) ACCTNO,
          (case when substr(cf.custodycd,4,1)='F' then '01233.086'
                when substr(cf.custodycd,4,1)='P' then '01231.086'
                else '01232.086' end) TK_GHICO

 from (
        SELECT   SE.txdate,FLD.CVALUE,
                 SUBSTR (SE.MSGACCT, 0, 10) acctno,
                 SUBSTR (SE.MSGACCT, 11, 6) codeid,
                 se.msgamt
          FROM   VW_TLLOG_ALL SE, VW_TLLOGFLD_ALL FLD, SEMORTAGE SE1
         WHERE      SE.tltxcd = '2232'
               AND SE.TXDATE=FLD.TXDATE
               AND SE.TXNUM=FLD.TXNUM
               AND FLD.FLDCD='13'
               AND SE.TXDATE=SE1.TXDATE(+)
               AND SE.TXNUM=SE1.TXNUM(+)
               AND SE1.DELTD<>'Y'
               AND SE.DELTD<>'Y' AND SE.TXSTATUS IN ('1','4','7')
               AND UPPER(NVL(FLD.CVALUE,'0000')) LIKE V_STRHDNUM
               AND SE.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
               AND SE.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
                 ) SE ,
         (select nVL(SB1.Parvalue,SB.Parvalue) Parvalue,  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
    nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
from sbsecurities sb, sbsecurities sb1
where nvl(sb.refcodeid,' ') = sb1.codeid(+) ) sb,afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
 where se.codeid = sb.codeid
       AND se.acctno = af.acctno
       AND af.custid = cf.custid
       --AND AF.ACTYPE NOT IN ('0000')
       --AND sb.tradeplace IN ('001', '002', '005','006')
       AND Cf.CUSTODYCD  LIKE V_CUSTODYCD
       AND sb.symbol     LIKE V_SYMBOL
       AND sb.tradeplace like V_TRADEPLACE
    Group by
        sb.tradeplace ,SE.CVALUE,
        se.Codeid ,
        REPLACE(sb.symbol,'_WFT',''),
        sb.Parvalue,
        substr(cf.custodycd,4,1)
      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
