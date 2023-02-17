SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0051" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PLSENT         in       varchar2
)
IS

-- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE
-- PERSON --------------DATE---------------------COMMENTS
-- QUYET.KIEU           11/02/2011               CREATE NEW
-- DIENNT               09/01/2012               EDIT
-- ---------   ------  -------------------------------------------
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_TYPE  VARCHAR2(10);

   V_CURRDATE date;
   v_flag number(2,0);

BEGIN
-- GET REPORT'S PARAMETERS


    V_CUSTODYCD := upper( PV_CUSTODYCD);
    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
     from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

/*
   IF  (LOWER(PV_TYPE) = 'tat toan')

   THEN
         V_TYPE := '2247' ;
   ELSE
         V_TYPE := '8815' ;
   END IF;
*/

   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
         V_STRAFACCTNO := '%';
   END IF;




-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT custodycd , PLSENT PLSENT, CF.FULLNAME,cf.idcode,cf.iddate, cf.idplace,cf.address, nvl(cf.mobilesms,' ') mobilesms, REPLACE( sb.symbol,'_WFT','') SYMBOL ,
 CASE WHEN sb.tradeplace ='002' THEN 'A. HNX' WHEN sb.tradeplace ='001' THEN 'B. HOSE' WHEN sb.tradeplace ='005' THEN 'C. UPCOM' END TRADEPLACE ,
 CASE WHEN sb.refcodeid IS  NULL THEN se.trade ELSE 0 END trade,
 CASE WHEN sb.refcodeid IS  NULL THEN se.blocked ELSE 0 END blocked,
 CASE WHEN sb.refcodeid IS not  NULL THEN se.trade ELSE 0 END trade_wft,
 CASE WHEN sb.refcodeid IS  NULL THEN se.blocked ELSE 0 END blocked_wft,
 se.trade+se.blocked total
 FROM sbsecurities sb,afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
            (SELECT max(msgacct) seacctno, max(decode(fldcd,'10',nvalue)) trade,max(decode(fldcd,'06',nvalue)) blocked
            FROM tllogfldall tlfld,tllogall tl
            WHERE tl.txnum = tlfld.txnum AND tl.txdate= tlfld.txdate
            AND tl.txdate BETWEEN to_date (F_DATE,'dd/mm/yyyy') AND to_date (t_DATE,'dd/mm/yyyy')
            AND tl.deltd <>'Y'
            AND tl.tltxcd ='2247'
            GROUP BY tl.txnum , tl.txdate )se
WHERE substr(se.seacctno,11)= sb.codeid
AND substr(se.seacctno,1,10)= af.acctno
AND af.custid = cf.custid
AND cf.custodycd LIKE V_CUSTODYCD
AND af.acctno LIKE V_STRAFACCTNO
 ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
