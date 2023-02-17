SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf10303_BK (
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

SELECT  * from (
  SELECT   to_char( rlsdate,'dd/mm/yyyy') i_date , to_char( lnschdid) lnschdid, lnprin, intamt, mnemonic
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
            AND ln.trfacctno =v_afacctno
            and ls.rlsdate <= v_t_date
    ) A
    WHERE a.lnprin+a.intamt >0
   -- order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;
    union all
   SELECT   ' ' i_date ,' ' lnschdid,    nvl( SUM(AMT),0) lnprin, nvl( SUM(feeamt),0) intamt , 'ung truoc' mnemonic FROM ADSCHD WHERE cleardt > v_t_date AND TXDATE <=v_t_date AND acctno = v_afacctno
   union all
   SELECT ' ' i_date ,' ' lnschdid,    -(CIDEPOFEEACR+DEPOFEEAMT -  nvl(TR.NAMT,0))  lnprin, 0 intamt, 'Phi luu ky' mnemonic
   FROM cimast CI ,(SELECT  SUM( CASE WHEN TXTYPE  ='C' THEN namt ELSE  -NAMT END ) namt,    acctno
                    FROM VW_CITRAN_GEN WHERE FIELD IN ('CIDEPOFEEACR','DEPOFEEAMT')
                    AND  BUSDATE >= v_t_date
                    GROUP BY acctno
                 ) TR
   WHERE CI.acctno = TR.Acctno (+)
   AND ci.acctno =v_afacctno)
   order by lnschdid

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
