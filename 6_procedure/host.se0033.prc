SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0033" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
       )
IS

-- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE 8878
-- PERSON : QUYET.KIEU
-- DATE : 26/04/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
BEGIN
-- GET REPORT'S PARAMETERS


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%';
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR


SELECT
    (case when sb.tradeplace='002' then 'HNX'
          when sb.tradeplace='001' then 'HOSE'
          when sb.tradeplace='005' then 'UPCOM' else '' end) san,
         nvl(  cf.fullname,'') fullname,
         nvl(cf.idcode ,'')idcode,
         nvl( cf.iddate ,'')iddate,
         nvl(cf.custodycd,'') custodycd,
         nvl(sb.symbol,'') codeid,
         nvl(tl.msgamt,'') sl_lole

  FROM   (SELECT   txdate,
                   SUBSTR (msgacct, 0, 10) acctno,
                   SUBSTR (msgacct, 11, 6) codeid,
                   msgamt
            FROM   tllog
           WHERE   tltxcd = '8878' AND DELTD = 'N'
          AND txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
           AND txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
          UNION ALL
          SELECT   txdate,
                   SUBSTR (msgacct, 0, 10) acctno,
                   SUBSTR (msgacct, 11, 6) codeid,
                   msgamt
            FROM   tllogall
           WHERE   tltxcd = '8878' AND DELTD = 'N'
        AND txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
           AND txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
           ) tl,
         afmast af,
         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
         sbsecurities sb
 WHERE       tl.acctno = af.acctno
         AND af.custid = cf.custid
         AND tl.codeid = sb.codeid
         AND sb.tradeplace IN ('001', '002', '005')
         AND Cf.CUSTODYCD LIKE V_CUSTODYCD
         AND tl.acctno LIKE V_STRAFACCTNO

         ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
