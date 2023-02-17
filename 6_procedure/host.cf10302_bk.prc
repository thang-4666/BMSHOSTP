SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf10302_BK (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
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
  v_deffeerate            NUMBER;
BEGIN
    V_STROPTION := upper(OPT);

  V_custodycd  := upper(pv_custodycd);
  V_afacctno  := upper(PV_AFACCTNO);

 SELECT getduedate( max(sbdate),'B','001',1) INTO  v_f_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND   sbdate <to_date(F_DATE,'DD/MM/YYYY');
 SELECT max(sbdate) INTO  v_t_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND  sbdate <=to_date(t_DATE,'DD/MM/YYYY');



BEGIN

 SELECT max(od.deffeerate) INTO v_deffeerate
 FROM afidtype afi, odtype od,afmast af
 WHERE afi.actype= od.actype
 AND  objname ='OD.ODTYPE'
 AND af.actype = afi.aftype
 AND af.acctno = v_afacctno;
EXCEPTION WHEN OTHERS
  THEN
v_deffeerate:=0;
END ;

OPEN PV_REFCURSOR
  FOR

   SELECT seinfo.symbol, (se.TRADE+SE.RECEIVING - nvl(TR.NAMT,0)) trade, sec.costprice,  seinfo.avgprice  ,seinfo.basicprice,
  -  (se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*(SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM')/100
-(se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*v_deffeerate/100
    fee_tax
   , (seinfo.avgprice-sec.costprice)*(se.TRADE+se.receiving - nvl(TR.NAMT,0))
   /* -(se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*(SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM')/100
    -(se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*v_deffeerate/100*/  pl
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END ) NAMT ,acctno
                    FROM vw_setran_gen WHERE field IN('TRADE','RECEIVING')
                    AND  BUSDATE > v_t_date
                    GROUP BY acctno
                 ) TR,vw_securities_info_hist seinfo,
     (select * from  vw_secostprice WHERE substr(acctno,1,10)= v_afacctno AND  txdate||acctno in
             (SELECT max(txdate)||acctno FROM vw_secostprice WHERE txdate <= v_t_date AND substr(acctno,1,10)= v_afacctno  GROUP BY acctno  ) )sec ,
                 sbsecurities sb
WHERE se.acctno = TR.Acctno (+)
and se.acctno = sec.acctno (+)
AND se.codeid = SB.codeid
AND seinfo.histdate = v_t_date
AND seinfo.codeid = sb.codeid
AND se.afacctno = v_afacctno
AND sb.sectype <>'004'
AND  (se.TRADE+SE.RECEIVING - nvl(TR.NAMT,0))>0;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
