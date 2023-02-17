SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf10301_BK (
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
BEGIN
    V_STROPTION := upper(OPT);


  V_custodycd  := upper(pv_custodycd);
  V_afacctno  := upper(PV_AFACCTNO);

 SELECT getduedate( max(sbdate),'B','001',1) INTO  v_f_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND   sbdate <to_date(F_DATE,'DD/MM/YYYY');
 SELECT max(sbdate) INTO  v_t_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND  sbdate <=to_date(t_DATE,'DD/MM/YYYY');



OPEN PV_REFCURSOR
  FOR
SELECT a.* FROM (
    SELECT  max(od.txdate) txdate,  sem.orderid ,'ban' typetran  , max(od.execqtty)||' '|| max(sb.symbol) des  , sum(se.outamt-se.inamt) PL,0 debit_credit ,max(-taxsellamt-feeacr) tax_sell ,
    0 income
    FROM secnet se, secmast sem, vw_odmast_all od ,sbsecurities sb
    WHERE se.outid= sem.autoid
        AND  sem.orderid = od.orderid
        AND od.codeid = sb.codeid
        AND od.execqtty>0
        AND od.afacctno =V_afacctno
        AND od.exectype ='NS'
        AND se.deltd <>'Y'
        AND od.txdate BETWEEN v_f_date AND v_t_date
        GROUP BY  sem.orderid
    UNION ALL
    SELECT od.txdate, od.orderid ,'mua' typetran, od.execqtty||' '|| sb.symbol des , 0 pl,0 debit_credit ,-taxsellamt-feeacr tax_sell ,0 income
    FROM vw_odmast_all od,sbsecurities sb
    WHERE od.exectype ='NB'AND od.codeid = sb.codeid
        AND od.execqtty>0
        AND od.afacctno = v_afacctno
        AND od.txdate BETWEEN v_f_date AND v_t_date
      UNION ALL

    SELECT busdate, txnum , '' typetran , txdesc  des ,NAMT pl, 0 debit_credit, 0 tax_sell,0 income
    FROM vw_citran_gen WHERE tltxcd IN ('3350','3354') AND field ='BALANCE' AND DELTD <>'Y'
     AND busdate BETWEEN v_f_date AND v_t_date
     AND acctno = v_afacctno
    UNION ALL
    SELECT busdate, txnum , '' typetran , txdesc  des ,0 pl, decode (txtype,'C',namt,'D',-namt)*DECODE (TLTXCD,'6668',-1,1) debit_credit, 0 tax_sell,0 income
    FROM vw_citran_gen
    WHERE (tltxcd NOT IN ('8855','8856','8865','8866','1162','0066','5540','5567','6691','6600','6690','6660','6621','8851','1153','5540','5567','5566','3350','3354')
           )
        AND acctno = v_afacctno
        AND field =decode (tltxcd,'6668','HOLDBALANCE','BALANCE')
        AND deltd <>'Y'
        AND busdate BETWEEN v_f_date AND v_t_date
    UNION ALL
    SELECT busdate, txnum , '' typetran , txdesc  des ,0 pl, decode (txtype,'C',nvl(namt* SEIF.basicprice,0),'D',-nvl(namt* SEIF.basicprice ,0)) debit_credit, 0 tax_sell,0 income
    FROM vw_setran_gen se ,vw_securities_info_hist seif
    WHERE tltxcd NOT IN ('8867','8868')
         AND afacctno = v_afacctno
         AND deltd <>'Y'
         and field ='TRADE'
         AND se.codeid = seif.codeid
         AND se.txdate= seif.histdate
          AND se.busdate BETWEEN v_f_date AND v_t_date
     UNION ALL
    SELECT busdate, txnum , '' typetran , txdesc  des ,0 pl, 0 debit_credit, 0 tax_sell, trunc(decode (txtype,'C',namt,'D',-namt)) income
    FROM vw_citran_gen
    WHERE ( tltxcd  IN ('1162','5540','5567')  OR   (TLTXCD IN( '1153') AND txtype ='D'))
        AND acctno = v_afacctno
        AND (CASE WHEN  tltxcd IN ('5540','5567') AND  instr(trdesc, utf8nums.C_CF1030_DEC)=0 THEN 1 ELSE 0 END  ) =0
        AND field ='BALANCE'
        AND deltd <>'Y'
        AND busdate BETWEEN v_f_date AND v_t_date)a
        ORDER BY txdate
        ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
