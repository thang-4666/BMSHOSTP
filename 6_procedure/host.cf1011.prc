SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1011" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   LOANAUTOID       IN      VARCHAR2
--   CUSTBANK         IN      VARCHAR2,
  -- PV_CUSTODYCD     IN       VARCHAR2,
  -- PV_AFACCTNO      IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO IN HOP DONG MO TIEU KHOAN GIAO DICH KY QUY
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        05-APR-2012 CREATED
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_CUSTBANK          varchar2(10);
    V_IN_DATE           VARCHAR2(15);
    V_LOANAUTOID          VARCHAR2(10);
    l_COMPANYNAME          VARCHAR2(100);


BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    --V_BRID := BRID;
    V_LOANAUTOID := LOANAUTOID;
    l_COMPANYNAME:= cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');

     OPEN PV_REFCURSOR FOR
        SELECT CF.custid, CF.custodycd, AF.acctno, cf.fullname, to_char(cf.dateofbirth,'DD/mm/yyyy') dateofbirth,
            cf.idcode, to_char(cf.iddate,'dd/mm/yyyy') iddate, cf.idplace, cf.address, cf.email, cf.phone, cf.fax,
            AF.mrcrlimit mrlimit, af.mrirate, af.mrmrate, af.mrlrate, lns.autoid, ln.acctno lnacctno,
            to_char(lns.rlsdate,'dd/mm/yyyy') rlsdate, lns.nml+lns.ovd+lns.paid rlsamt,
            to_char(lns.overduedate,'dd/mm/yyyy') overduedate, lns.intnmlacr+lns.intdue+lns.intovd+lns.intovdprin intprin,
            lns.feeintnmlacr+lns.feeintovdacr+lns.feeintnmlovd+lns.feeintdue+lns.feeintdue+lns.feeintovd feeintprin,
            ROUND(LEAST(sec.SEASS, sec.MRCRLIMITMAX - dfodamt)) SECAMOUNT,
            ROUND(CASE WHEN sec.OUTSTANDING > 0 THEN 0 ELSE ABS(sec.OUTSTANDING) END) LOANAMT,
            NVL(LN.CUSTBANK,l_COMPANYNAME) CUSTBANK, NVL(CF2.FULLNAME,l_COMPANYNAME) BANKNAME, 0 aft_lnamt
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
            AFMAST AF,
            CIMAST CI,
            aftype aft, mrtype mrt, v_getsecmarginratio sec, lnmast ln, lnschd lns, cfmast cf2
        WHERE CF.custid = AF.custid
            AND af.actype = aft.actype AND aft.mrtype = mrt.actype AND mrt.mrtype IN ('S','T')
            AND lns.acctno = ln.acctno
            and ln.trfacctno = af.acctno
            and af.custid = cf.custid
            and af.acctno = ci.afacctno
            and lns.reftype in ('P','GP')
            and ln.ftype = 'AF'
            AND sec.afacctno = af.acctno
            AND LN.CUSTBANK = CF2.CUSTID (+)
            AND LNS.autoid = V_LOANAUTOID;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
