SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0041 (
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
   PLSENT         IN       VARCHAR2
)
IS

-- RP NAME : Danh sach nguoi so huu de rut chung khoan 11B/LK
-- PERSON : QUYET.KIEU
-- DATE :   28/04/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------
   V_SYMBOL  VARCHAR2 (20);
   V_STRBRID  VARCHAR2 (10);

   V_CUSTODYCD VARCHAR2 (15);
   V_TRADEPLACE VARCHAR2 (15);

   V_STRPLSENT VARCHAR2 (100);

BEGIN
-- GET REPORT'S PARAMETERS

   V_STRBRID := pv_BRID;

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

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT
         nvl(V_STRBRID,' ') branchID, V_STRPLSENT PLSENT, nvl(A2.cdcontent ,'') san,
         nvl(  cf.fullname,'') fullname,
         nvl(cf.custodycd,'') custodycd,
         nvl(cf.idcode ,'')idcode,
         nvl( cf.iddate ,'')iddate,
           (Case when A1.cdval='001' then '1'
              when A1.cdval='005' then '3'
           else '4' end
        ) IDTYPE ,
         nvl(sb.symbol,'') codeid,
         nvl(iss.fullname,'') CK_Name,
         Sum(nvl(tl.msgamt,'')) So_luong,
         nvl(sb.PARVALUE,'') Menh_gia,
         nvl(PV_SYMBOL,'') PV_SYMBOL,
         V_TRADEPLACE V_TRADEPLACE ,
         V_CUSTODYCD V_CUSTODYCD,
         V_SYMBOL V_SYMBOL,
         (case when substr(cf.custodycd,4,1)='F' then '01263.009'
                when substr(cf.custodycd,4,1)='P' then '01261.009'
                else '01262.009' end) TK_NO,
        (case when substr(cf.custodycd,4,1)='F' then '01213.009'
                when substr(cf.custodycd,4,1)='P' then '01211.009'
                else '01212.009' end) TK_CO
  FROM(
    SELECT txdate, afacctno acctno ,codeid ,withdraw  msgamt From
        sewithdrawdtl
    where status in ('A','C')
     /*txdatetxnum in
        (Select msgacct from  tLlog
         WHERE tltxcd = '2292'
            AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
            AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        Union all
        Select msgacct from  tLlogALl
         WHERE       tltxcd = '2292'
         AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        )*/
 ) tl,

         afmast af,
         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
         (select nVL(SB1.Parvalue,SB.Parvalue) Parvalue,  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
    nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID, sb.symbol symbol1, nvl(SB1.issuerid,SB.issuerid) issuerid
from sbsecurities sb, sbsecurities sb1
where nvl(sb.refcodeid,' ') = sb1.codeid(+)) sb,
         issuers iss,
         ALLCODE A1,
         ALLCODE A2
 WHERE       tl.acctno = af.acctno
         AND af.custid = cf.custid
         AND AF.ACTYPE NOT IN ('0000')
         AND tl.codeid = sb.codeid
      --   AND sb.tradeplace IN ('001', '002', '005')
         -----------------
         AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'IDTYPE'
         AND A1.CDVAL = CF.IDTYPE
         AND iss.issuerid = sb.issuerid
         AND A2.CDTYPE = 'SE' AND A2.CDNAME = 'TRADEPLACE'
         AND A2.CDVAL = sb.tradeplace
         AND sb.tradeplace = A2.cdval
         AND Cf.CUSTODYCD LIKE V_CUSTODYCD
         AND tl.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND tl.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
         AND sb.symbol    LIKE V_SYMBOL
         AND sb.tradeplace like V_TRADEPLACE
         --AND sb.tradeplace = PV_TRADEPLACE
        group by
        A2.cdcontent ,
        cf.fullname,
        cf.custodycd,
        cf.idcode,
        cf.iddate,
        A1.cdval,
        sb.symbol,
        iss.fullname,
        sb.PARVALUE,
        PV_SYMBOL, substr(cf.custodycd,4,1)
      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
