SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0030" (
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

BEGIN
SELECT nvl( sum(outamt -inamt),0) INTO v_pl FROM secnet
WHERE  netdate BETWEEN v_f_date AND v_t_date
AND deltd <>'Y'
AND acctno = v_afacctno;
EXCEPTION WHEN OTHERS
  THEN
v_pl:=0;
END ;


BEGIN
SELECT sum(-taxsellamt-feeacr ) INTO V_Fee_Tax
FROM vw_odmast_all od
WHERE od.txdate BETWEEN v_f_date AND v_t_date
AND od.afacctno = v_afacctno;

EXCEPTION WHEN OTHERS
  THEN
V_Fee_Tax:=0;
END ;


BEGIN
SELECT sum(msgamt) INTO V_interest_received  FROM vw_tllog_all tl
WHERE tl.tltxcd ='1162'
AND tl.txdate BETWEEN v_f_date AND v_t_date
AND tl.msgacct = v_afacctno;

EXCEPTION WHEN OTHERS
  THEN
V_interest_received:=0;
END ;

BEGIN
SELECT sum(lnlog.intpaid)  INTO V_interest_paid
FROM  vw_lnschdlog_all lnlog,vw_lnschd_all lns, lnmast ln
WHERE lnlog.autoid = lns.autoid
AND lns.acctno = ln.acctno
AND ln.trfacctno = v_afacctno
AND lnlog.txdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
V_interest_paid:=0;
END ;

BEGIN
SELECT sum(lnlog.intpaid)  INTO V_interest_paid
FROM  vw_lnschdlog_all lnlog,vw_lnschd_all lns, lnmast ln
WHERE lnlog.autoid = lns.autoid
AND lns.acctno = ln.acctno
AND ln.trfacctno = v_afacctno
AND lnlog.txdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
V_interest_paid:=0;
END ;


BEGIN
SELECT sum( msgamt) INTO v_cash_deposits FROM vw_tllog_all tl
WHERE tltxcd IN ('1141','1131') AND deltd <>'Y'
AND msgacct = v_afacctno
AND tl.txdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
v_cash_deposits:=0;
END ;


BEGIN
SELECT sum( msgamt) INTO v_cash_Withdraw FROM vw_tllog_all tl
WHERE tltxcd IN ('1101','1111','1132') AND deltd <>'Y'
AND msgacct = v_afacctno
AND tl.txdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
v_cash_Withdraw:=0;
END ;


BEGIN
SELECT BALANCE -  nvl(TR.NAMT,0)  INTO  v_opend_balance
FROM cimast CI ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMt END ) NAMT ,acctno
                    FROM vw_citran_gen WHERE field IN ('BALANCE', 'RECEIVING')
                    AND  BUSDATE >= v_f_date
                    GROUP BY acctno
                 ) TR
WHERE CI.acctno = TR.Acctno (+)
AND ci.acctno =v_afacctno
GROUP BY ci.acctno;

EXCEPTION WHEN OTHERS
  THEN
v_opend_balance:=0;
END ;

-- Tai san qua khu
BEGIN

SELECT (se.TRADE - nvl(TR.NAMT,0))*seinfo.marginprice  INTO v_seamt
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END ) NAMT ,acctno
                    FROM vw_setran_gen WHERE field ='TRADE'
                    AND  BUSDATE > v_f_date
                    GROUP BY acctno
                 ) TR,securities_info_hist seinfo
WHERE se.acctno = TR.Acctno (+)
AND se.codeid = se.codeid
AND seinfo.histdate = v_f_date
;

EXCEPTION WHEN OTHERS
  THEN
v_seamt:=0;
END ;







OPEN PV_REFCURSOR
  FOR
   SELECT v_pl pl FROM dual ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
