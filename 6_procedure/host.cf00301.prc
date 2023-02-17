SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00301" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
  v_custodycd varchar2(10);
  v_afacctno  varchar2(10);
  v_pl        NUMBER;
  V_Fee_Tax   NUMBER;
  V_interest_received   NUMBER;
  V_interest_paid       NUMBER;

  v_f_date    DATE ;
  v_t_date    DATE ;
  v_opend_balance       NUMBER;
  v_cash_deposits       NUMBER;
  v_cash_Withdraw       NUMBER;
  v_seamt               NUMBER;
BEGIN
    V_STROPTION := upper(OPT);


  V_custodycd  := upper(pv_custodycd);
  V_afacctno  := upper(pv_custodycd);
  v_f_date:= to_date(F_DATE,'DD/MM/YYYY');
  v_t_date:= to_date(T_DATE,'DD/MM/YYYY');




OPEN PV_REFCURSOR
  FOR

    SELECT  od.txdate,  sem.orderid ,'ban' typetran  , od.execqtty||' '|| sb.symbol des  , se.outamt-se.inamt PL,0 debit_credit ,-taxsellamt-feeacr tax_sell ,
    0 income
    FROM secnet se, secmast sem, vw_odmast_all od ,sbsecurities sb
    WHERE se.outid= sem.autoid
    AND  sem.orderid = od.orderid
    AND od.codeid = sb.codeid
    AND od.afacctno =V_afacctno
    AND od.txdate BETWEEN v_f_date AND v_t_date
    UNION ALL
    SELECT od.txdate, od.orderid ,'mua' typetran, od.execqtty||' '|| sb.symbol des , 0 pl,0 debit_credit ,-taxsellamt-feeacr tax_sell ,0 income
    FROM vw_odmast_all od,sbsecurities sb WHERE od.exectype ='NB'AND od.codeid = sb.codeid
    AND od.afacctno = v_afacctno
    AND od.txdate BETWEEN v_f_date AND v_t_date
    ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
