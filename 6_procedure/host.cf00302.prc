SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00302" (
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

   SELECT seinfo.symbol, (se.TRADE - nvl(TR.NAMT,0)) trade, se.costprice,  seinfo.avgprice  ,  0 fee_tax , 0 pl
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END ) NAMT ,acctno
                    FROM vw_setran_gen WHERE field ='TRADE'
                    AND  BUSDATE > v_t_date
                    GROUP BY acctno
                 ) TR,securities_info_hist seinfo,sbsecurities sb
WHERE se.acctno = TR.Acctno (+)
AND se.codeid = se.codeid
AND seinfo.histdate = v_t_date
AND seinfo.codeid = sb.codeid
AND se.afacctno = v_afacctno
AND sb.sectype <>'004'
AND  (se.TRADE - nvl(TR.NAMT,0))>0;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
