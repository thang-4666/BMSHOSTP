SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3006" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   LOANAUTOID       IN       VARCHAR2,
   TLID             IN       VARCHAR2
--   CUSTBANK         IN      VARCHAR2,
  -- PV_CUSTODYCD     IN       VARCHAR2,
  -- PV_AFACCTNO      IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO IN GIAY DE NGHI GIAI NGAN KIEM KHE UOC NHAN NO
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        05-APR-2012 CREATED
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_CUSTBANK          varchar2(10);
    V_IN_DATE           VARCHAR2(15);
    V_LOANAUTOID          VARCHAR2(10);
    V_LOANAMT           NUMBER;

     V_INBRID        VARCHAR2(4);
     V_STRBRID      VARCHAR2 (50);

     v_TLID varchar2(4);
     l_companyshortname varchar2(10);
BEGIN
    -- GET REPORT'S PARAMETERS
     v_TLID := TLID;
     V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
    --V_BRID := BRID;
    V_LOANAUTOID := LOANAUTOID;
    l_companyshortname:=cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');

    -- TINH DU NO THEO NGUON

    -- LAY DU LIEU CHO BAO CAO
    OPEN PV_REFCURSOR FOR
        SELECT CF.custid, CF.custodycd, AF.acctno, cf.fullname, to_char(cf.dateofbirth,'DD/mm/yyyy') dateofbirth,
            cf.idcode, to_char(cf.iddate,'dd/mm/yyyy') iddate, cf.idplace, cf.address, cf.email, cf.phone, cf.fax,
            af.mrirate, af.mrmrate, af.mrlrate, lns.autoid, LNS.acctno lnacctno, cf.mrloanlimit,
            to_char(lns.rlsdate,'dd/mm/yyyy') rlsdate, RLS.rlsamt,
            to_char(lns.overduedate,'dd/mm/yyyy') overduedate, lns.intnmlacr+lns.intdue+lns.intovd+lns.intovdprin intprin,
            lns.feeintnmlacr+lns.feeintovdacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintdue+lns.feeintovd feeintprin,
            RLS.seass SECAMOUNT,
            RLS.totalodamt LOANAMT,
            NVL(RLS.CUSTBANK,l_companyshortname) CUSTBANK, NVL(CF2.FULLNAME,l_companyshortname) BANKNAME, nvl(cf2.shortname,l_companyshortname) bankshortname,
            RLS.totalprinamt aft_lnamt,
            RLS.rate intrate, RLS.cfrate feerate,
            RLS.marginrate marginrate, RLS.mrcrlimitmax MRLIMIT
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, CFMAST CF2, rlsrptlog_eod RLS,vw_lnschd_all LNS
                            --aftype aft, mrtype mrt
        WHERE CF.custid = AF.custid
            --AND af.actype = aft.actype AND aft.mrtype = mrt.actype AND mrt.mrtype IN ('S','T')
            AND lns.autoid = RLS.lnschdid
            and RLS.afacctno = af.acctno
            and af.custid = cf.custid
            AND RLS.CUSTBANK = CF2.CUSTID (+)
            AND LNS.autoid = V_LOANAUTOID
           -- AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID )
        ;

        /*SELECT a.*, CASE WHEN a.custbank = l_companyshortname THEN a.mrloanlimit
                ELSE CASE WHEN a.custid IN (SELECT custid FROM cflimitext cfle WHERE cfle.lmsubtype = 'DFMR') THEN nvl(cfle.lmamt,0)
                            ELSE nvl(cfl.lmamt,0) END END mrlimit
        FROM
        (
            SELECT CF.custid, CF.custodycd, AF.acctno, cf.fullname, to_char(cf.dateofbirth,'DD/mm/yyyy') dateofbirth,
                cf.idcode, to_char(cf.iddate,'dd/mm/yyyy') iddate, cf.idplace, cf.address, cf.email, cf.phone, cf.fax,
                af.mrirate, af.mrmrate, af.mrlrate, lns.autoid, ln.acctno lnacctno, cf.mrloanlimit,
                to_char(lns.rlsdate,'dd/mm/yyyy') rlsdate, lns.nml+lns.ovd+lns.paid rlsamt,
                to_char(lns.overduedate,'dd/mm/yyyy') overduedate, lns.intnmlacr+lns.intdue+lns.intovd+lns.intovdprin intprin,
                lns.feeintnmlacr+lns.feeintovdacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintdue+lns.feeintovd feeintprin,
                ROUND(DECODE(AF.IST2,'Y',LEAST(sec.SEMAXCALLASS, sec.MRCRLIMITMAX), LEAST(sec.SETOTALCALLASS, sec.MRCRLIMITMAX))) SECAMOUNT,
                --ROUND(DECODE(AF.IST2,'Y',CASE WHEN sec.OUTSTANDINGT2 > 0 THEN 0 ELSE ABS(sec.OUTSTANDINGT2) END,CASE WHEN sec.OUTSTANDING > 0 THEN 0 ELSE ABS(sec.OUTSTANDING) END)) LOANAMT,
                V_LOANAMT LOANAMT,
                NVL(LN.CUSTBANK,l_companyshortname) CUSTBANK, NVL(CF2.FULLNAME,l_companyshortname) BANKNAME, nvl(cf2.shortname,l_companyshortname) bankshortname,
                --ROUND(DECODE(AF.IST2,'Y',CASE WHEN sec.OUTSTANDINGT2 > 0 THEN 0 ELSE ABS(sec.OUTSTANDINGT2) END,CASE WHEN sec.OUTSTANDING > 0 THEN 0 ELSE ABS(sec.OUTSTANDING) END)) aft_lnamt,
                V_LOANAMT aft_lnamt,
                CASE WHEN ln.oprinnml+ln.oprinovd+ln.oprinpaid>0 THEN ln.orate2 ELSE ln.rate2 END intrate, ln.cfrate2 feerate,
                decode(AF.IST2,'Y',sec.rlsmarginrate,sec.marginrate) marginrate
            FROM CFMAST CF,
                (SELECT AF.*, CASE WHEN AF.TRFBUYEXT * AF.TRFBUYRATE > 0 THEN 'Y' ELSE 'N' END IST2 FROM AFMAST AF) AF,
                aftype aft, mrtype mrt, v_getsecmarginratio sec, lnmast ln, lnschd lns, cfmast cf2
            WHERE CF.custid = AF.custid
                AND af.actype = aft.actype AND aft.mrtype = mrt.actype AND mrt.mrtype IN ('S','T')
                AND lns.acctno = ln.acctno
                and ln.trfacctno = af.acctno
                and af.custid = cf.custid
                and lns.reftype in ('P','GP')
                and ln.ftype = 'AF'
                AND sec.afacctno = af.acctno
                AND LN.CUSTBANK = CF2.CUSTID (+)
                AND LNS.autoid = V_LOANAUTOID
        ) a, cflimitext cfle, cflimit cfl
        WHERE a.custbank = cfl.bankid (+)
            AND a.custbank = cfle.bankid (+)
            AND a.custid = cfle.custid (+)
        ;*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
