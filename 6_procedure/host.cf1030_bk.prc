SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1030_BK (
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
  V_securities_deposit  NUMBER;
  V_securities_Withdraw NUMBER;
  v_fullname varchar2(100);
  v_netpl               NUMBER;
  v_end_balance         NUMBER;
  v_Unrealized_PL       NUMBER;
  v_interest_not_paid   NUMBER;
  V_total_account       NUMBER;
  v_balance             NUMBER;
  v_deffeerate          NUMBER;
  v_lnprin              NUMBER;
  V_adv                 NUMBER;
  v_Interest_Receivable  NUMBER;
  v_receiving          NUMBER;
  v_balance_td         NUMBER;
   v_intnmlacr_td       NUMBER;
   v_Op_balance         NUMBER;
   v_Op_receiving         NUMBER;
   v_receiving_tax_fee  NUMBER ;
   v_op_receiving_tax_fee  NUMBER ;
 BEGIN



   V_STROPTION := upper(OPT);


  V_custodycd  := upper(pv_custodycd);
  V_afacctno  := upper(PV_AFACCTNO);

 SELECT getduedate( max(sbdate),'B','001',1) INTO  v_f_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND   sbdate <to_date(F_DATE,'DD/MM/YYYY');
 SELECT max(sbdate) INTO  v_t_date FROM sbcldr WHERE cldrtype='000' AND holiday ='N' AND  sbdate <=to_date(t_DATE,'DD/MM/YYYY');


SELECT fullname INTO v_fullname FROM cfmast WHERE custodycd =V_custodycd;


BEGIN
SELECT nvl( sum(NVL(outamt,0) - NVL(inamt,0)),0) INTO v_pl FROM secnet
WHERE  netdate BETWEEN v_f_date AND v_t_date
AND deltd <>'Y'
AND acctno = v_afacctno;
EXCEPTION WHEN OTHERS
  THEN
v_pl:=0;
END ;


BEGIN
SELECT NVL(sum(-taxsellamt-feeacr ),0) INTO V_Fee_Tax
FROM vw_odmast_all od
WHERE od.txdate BETWEEN v_f_date AND v_t_date
AND od.afacctno = v_afacctno;

EXCEPTION WHEN OTHERS
  THEN
V_Fee_Tax:=0;
END ;


BEGIN
SELECT NVL( sum(trunc(msgamt)),0) INTO V_interest_received  FROM vw_tllog_all tl
WHERE tl.tltxcd ='1162'
AND tl.txdate BETWEEN v_f_date AND v_t_date
AND tl.msgacct = v_afacctno;

EXCEPTION WHEN OTHERS
  THEN
V_interest_received:=0;
END ;

BEGIN
SELECT - NVL( sum(lnlog.intpaid),0)  INTO V_interest_paid
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
SELECT  nvl(sum(namt),0) INTO v_cash_deposits FROM vw_citran_gen
WHERE --tltxcd NOT IN ('8855','8856','8865','8866','1162','0066','5540','5567')
tltxcd NOT IN ('8855','8856','8865','8866','1162','0066','6691','6600','6690','6660','6621','1153','8851','5540','5567','5566')
AND acctno = v_afacctno
AND txtype= decode (tltxcd,'6668','D','C')
AND deltd <>'Y'
AND field  = decode (tltxcd,'6668','HOLDBALANCE','BALANCE')
AND busdate BETWEEN v_f_date AND v_t_date;
EXCEPTION WHEN OTHERS
  THEN
v_cash_deposits:=0;
END ;


BEGIN

SELECT - nvl(sum(namt),0) INTO v_cash_Withdraw FROM vw_citran_gen
WHERE
tltxcd NOT IN ('8855','8856','8865','8866','1162','0066','6691','6600','6690','6660','6621','8851','5540','5567','5566')
AND acctno = v_afacctno
AND field =  'BALANCE'
AND txtype='D'
AND deltd <>'Y'
AND busdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
v_cash_Withdraw:=0;
END ;


BEGIN

SELECT  nvl(sum(namt* SEIF.basicprice ),0) INTO V_securities_deposit
FROM vw_setran_gen se ,vw_securities_info_hist seif
WHERE tltxcd NOT IN ('8867','8868')
AND afacctno = v_afacctno
AND txtype='C'
AND deltd <>'Y'
and field ='TRADE'
AND se.codeid = seif.codeid
AND se.txdate= seif.histdate
AND se.busdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
V_securities_deposit:=0;
END ;

BEGIN

SELECT  -nvl(sum(namt* SEIF.basicprice ),0) INTO V_securities_Withdraw
FROM vw_setran_gen se ,vw_securities_info_hist seif
WHERE tltxcd NOT IN ('8867','8868')
AND afacctno = v_afacctno
AND txtype='D'
AND deltd <>'Y'
and field ='TRADE'
AND se.codeid = seif.codeid
AND se.txdate= seif.histdate
AND se.busdate BETWEEN v_f_date AND v_t_date;

EXCEPTION WHEN OTHERS
  THEN
v_cash_deposits:=0;
END ;


BEGIN
SELECT BALANCE -  nvl(TR.NAMT_BALANCE,0),RECEIVING - nvl(TR.NAMT_RECEIVING,0)  INTO  v_Op_balance,v_Op_receiving
FROM cimast CI ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' AND field ='BALANCE' THEN namt
                                   WHEN TXTYPE  ='D' AND field ='BALANCE' THEN -NAMt
                             ELSE 0 END ) NAMT_BALANCE,
                              SUM( CASE WHEN TXTYPE  ='C' AND field ='RECEIVING' THEN namt
                                   WHEN TXTYPE  ='D' AND field ='RECEIVING' THEN -NAMt
                             ELSE 0 END ) NAMT_RECEIVING
                                  ,acctno
                    FROM VW_CITRAN_GEN WHERE FIELD IN ('BALANCE','RECEIVING')
                    AND  BUSDATE >= v_f_date
                    GROUP BY acctno
                 ) TR
WHERE CI.acctno = TR.Acctno (+)
AND ci.acctno =v_afacctno
;

EXCEPTION WHEN OTHERS
  THEN
v_Op_balance:=0;
v_Op_receiving:=0;
END ;



BEGIN
SELECT BALANCE -  nvl(TR.NAMT_BALANCE,0),RECEIVING - nvl(TR.NAMT_RECEIVING,0)  INTO  v_balance,v_receiving
FROM cimast CI ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' AND field ='BALANCE' THEN namt
                                   WHEN TXTYPE  ='D' AND field ='BALANCE' THEN -NAMt
                             ELSE 0 END ) NAMT_BALANCE,
                              SUM( CASE WHEN TXTYPE  ='C' AND field ='RECEIVING' THEN namt
                                   WHEN TXTYPE  ='D' AND field ='RECEIVING' THEN -NAMt
                             ELSE 0 END ) NAMT_RECEIVING
                                  ,acctno
                    FROM VW_CITRAN_GEN WHERE FIELD IN ('BALANCE','RECEIVING')
                    AND  BUSDATE > v_t_date
                    GROUP BY acctno
                 ) TR
WHERE CI.acctno = TR.Acctno (+)
AND ci.acctno =v_afacctno
;

EXCEPTION WHEN OTHERS
  THEN
v_balance:=0;
v_receiving:=0;
END ;

--PHI THUE CUA LENH CHO NHAN VE NGAY T DATE


BEGIN
SELECT nvl( -SUM(FEEACR+taxsellamt),0) INTO v_receiving_tax_fee FROM vw_odmast_all od
WHERE  TXDATE BETWEEN get_t_date (v_t_date,2)AND v_t_date AND od.afacctno = v_afacctno AND od.exectype ='NS' ;

EXCEPTION WHEN OTHERS
  THEN
v_receiving_tax_fee:=0;
END ;



BEGIN
SELECT nvl(-SUM(FEEACR+taxsellamt),0) INTO v_op_receiving_tax_fee  FROM vw_odmast_all od
WHERE  TXDATE BETWEEN get_t_date (v_f_date,2)AND v_f_date AND od.afacctno = v_afacctno AND od.exectype ='NS' ;

EXCEPTION WHEN OTHERS
  THEN
v_op_receiving_tax_fee:=0;
END ;


-- Tai san qua khu
BEGIN

SELECT ROUND( nvl( sum((se.TRADE+se.receiving - nvl(TR.NAMT,0))*nvl( fn_costprice_secmast(SE.acctno,v_f_date ),0)) ,0) )  INTO v_seamt
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END) NAMT ,acctno
                    FROM vw_setran_gen WHERE field in('TRADE','RECEIVING')
                    AND  BUSDATE >= v_f_date
                    GROUP BY acctno
                 ) TR
WHERE se.acctno = TR.Acctno (+)
AND se.afacctno = v_afacctno
;


/*SELECT nvl( sum((se.TRADE+se.receiving - nvl(TR.NAMT,0))*seco.costprice) ,0)   INTO v_seamt
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END ) NAMT ,acctno
                    FROM vw_setran_gen WHERE field in('TRADE','RECEIVING')
                    AND  BUSDATE >= v_f_date
                    GROUP BY acctno
                 ) TR,(select * from  vw_secostprice WHERE substr(acctno,1,10)= v_afacctno AND  txdate||acctno in
             (SELECT max(txdate)||acctno FROM vw_secostprice WHERE txdate <= v_f_date AND substr(acctno,1,10)= v_afacctno  GROUP BY acctno  ) ) seco
WHERE se.acctno = TR.Acctno (+)
AND se.acctno = seco.acctno
AND se.afacctno = v_afacctno;*/



EXCEPTION WHEN OTHERS
  THEN
v_seamt:=0;
END ;

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


BEGIN

 SELECT ROUND(sum( (seinfo.avgprice-fn_costprice_secmast(SE.acctno,v_t_date))*(se.TRADE+SE.RECEIVING - nvl(TR.NAMT,0))))
  /*  -(se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*(SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM')/100
    -(se.TRADE - nvl(TR.NAMT,0))*seinfo.avgprice*v_deffeerate/100 )*/ into v_Unrealized_PL
FROM SEMAST SE ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE -NAMT END ) NAMT ,acctno
                    FROM vw_setran_gen WHERE field IN('TRADE','RECEIVING')
                    AND  BUSDATE > v_t_date
                    GROUP BY acctno
                 ) TR,vw_securities_info_hist seinfo,
                 sbsecurities sb
WHERE se.acctno = TR.Acctno (+)
AND se.codeid = SB.codeid
AND seinfo.histdate = v_t_date
AND seinfo.codeid = sb.codeid
AND se.afacctno = v_afacctno
AND sb.sectype <>'004'
AND  (se.TRADE+SE.RECEIVING - nvl(TR.NAMT,0))>0;

EXCEPTION WHEN OTHERS
  THEN
v_Unrealized_PL:=0;
END ;


BEGIN
SELECT - nvl(sum(intamt),0) INTO v_interest_not_paid
    FROM (
        select NVL(DF.ISVSD,'N') ISVSD,
            decode (NVL(DF.ISVSD,'N'),'Y', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','')||'-VSD', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','') ) rlstype,
            cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate, ls.autoid lnschdid,
            ls.nml + ls.ovd +ls.paid rlsprin,
            ls.paid - nvl(lg.paid,0) paid, ls.nml + ls.ovd - nvl(lg.nml,0) - nvl(lg.ovd,0) lnprin,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic,substr(af.acctno,1,4) brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > v_t_date
            group by autoid) lg,

            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.actype = aft.actype
            AND af.acctno LIKE v_afacctno
            and ls.rlsdate <= v_t_date
    ) A
    WHERE a.intamt >0    order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;


EXCEPTION WHEN OTHERS
  THEN
v_interest_not_paid:=0;
END ;


BEGIN
SELECT - nvl(sum(lnprin),0) INTO v_lnprin
    FROM (
        select NVL(DF.ISVSD,'N') ISVSD,
            decode (NVL(DF.ISVSD,'N'),'Y', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','')||'-VSD', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','') ) rlstype,
            cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate, ls.autoid lnschdid,
            ls.nml + ls.ovd +ls.paid rlsprin,
            ls.paid - nvl(lg.paid,0) paid, ls.nml + ls.ovd - nvl(lg.nml,0) - nvl(lg.ovd,0) lnprin,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic,substr(af.acctno,1,4) brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate >= v_f_date
            group by autoid) lg,

            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.actype = aft.actype
            AND af.acctno LIKE v_afacctno
            and ls.rlsdate <= v_f_date
    ) A
    WHERE a.lnprin >0    order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;


EXCEPTION WHEN OTHERS
  THEN
v_lnprin :=0;
END ;

BEGIN

 SELECT -nvl( SUM(AMT),0) INTO V_adv FROM ADSCHD WHERE cleardt > v_f_date AND TXDATE <=v_f_date AND acctno = v_afacctno;

EXCEPTION WHEN OTHERS
  THEN
V_adv:=0;
END ;


-- lai tien gui chua tra
BEGIN

SELECT nvl( sum(intamt),0) INTO v_Interest_Receivable  FROM ciinttran WHERE acctno =v_afacctno
AND frdate between to_date( '01'|| to_char( frdate,'MM/yyyy'),'dd/mm/yyyy') AND  to_date( '25'|| to_char( frdate,'MM/yyyy'),'dd/mm/yyyy');

EXCEPTION WHEN OTHERS
  THEN
V_adv:=0;
END ;

-- tien gui tiet kiem
BEGIN
SELECT  nvl(sum( tdm.balance - nvl( tr.namt_balance,0)),0)   ,
                    nvl( sum( tdm.balance - nvl( tr.namt_INTNMLACR,0)),0)   INTO v_balance_td,v_intnmlacr_td
         FROM tdmast  tdm,
(
    SELECT sum(CASE WHEN  FLDTYPE ='C' AND APP.FIELD ='BALANCE' THEN  namt WHEN FLDTYPE ='D' AND APP.FIELD ='BALANCE' THEN - NAMT END) namt_balance,
           sum(CASE WHEN  FLDTYPE ='C' AND APP.FIELD ='INTNMLACR' THEN  namt WHEN FLDTYPE ='D' AND APP.FIELD ='INTNMLACR' THEN - NAMT END) namt_INTNMLACR,
           acctno
    FROM
    (SELECT * FROM tdtran UNION ALL SELECT * FROM tdtrana) td ,apptx app
        WHERE td.txcd = app.txcd
        AND app.apptype='TD'
        AND APP.FIELD in('BALANCE','INTNMLACR')
        GROUP BY acctno) tr
 WHERE tdm.acctno = tr.acctno  (+)
 GROUP BY afacctno;

EXCEPTION WHEN OTHERS
  THEN
v_balance_td:=0;
v_intnmlacr_td:=0;
END ;


v_opend_balance:= v_op_balance+v_op_receiving +v_seamt+v_lnprin+V_adv+v_op_receiving_tax_fee;


v_netpl:= v_pl + V_Fee_Tax + V_interest_received + V_interest_paid ;

v_end_balance := v_opend_balance+ v_netpl +v_cash_deposits+v_cash_Withdraw
 + V_securities_deposit+ V_securities_Withdraw ;

V_total_account:=v_end_balance+v_Unrealized_PL+v_interest_not_paid + v_Interest_Receivable;




OPEN PV_REFCURSOR
  FOR
   SELECT  v_afacctno afacctno , v_fullname fullname,v_pl pl,V_Fee_Tax fee_tax,V_interest_received interest_received,V_interest_paid interest_paid,v_netpl netpl,
   v_cash_deposits cash_deposits, v_cash_Withdraw cash_Withdraw, v_opend_balance opend_balance,
   V_securities_deposit  securities_deposit,V_securities_Withdraw securities_Withdraw, v_end_balance end_balance,
   v_Unrealized_PL  Unrealized_PL, v_interest_not_paid interest_not_paid,V_total_account total_account,v_Interest_Receivable Interest_Receivable,
   v_receiving + v_receiving_tax_fee cireceiving, v_balance cibanlance,v_balance_td balance_td,v_intnmlacr_td  intnmlacr_td,v_receiving_tax_fee receiving_tax_fee
   FROM dual ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
