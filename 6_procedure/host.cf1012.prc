SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1012" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
    I_BRID           IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO IN HOP DONG HO TRO CHAM THANH TOAN TIEN MUA CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        09-APR-2012 CREATED
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_BRID              VARCHAR2(4);

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := pv_BRID;

     OPEN PV_REFCURSOR FOR
        SELECT CF.custid, CF.custodycd, AF.acctno, cf.fullname, to_char(cf.dateofbirth,'DD/mm/yyyy') dateofbirth,
            cf.idcode, to_char(cf.iddate,'dd/mm/yyyy') iddate, cf.idplace, cf.address, cf.email, cf.phone, cf.fax,
            AF.mrcrlimit mrlimit, af.mrirate, af.mrmrate, af.mrlrate, TO_CHAR(AF.opndate,'DD/MM/YYYY') opndate, nvl(cfr.fullname,'') authfullname, '' authlicense,
            '' authdate, sys1.varvalue BVSCREP, sys2.varvalue BVSCREPPOSITION, sys3.varvalue BVSCREPAUTH,
             sys14.varvalue BVSADDRESS, sys15.varvalue BVSPHONE, sys16.varvalue BVSFAX
            , sys17.varvalue BVSTITLE,
              sys4.varvalue BVSCBANKACCT, sys5.varvalue BVSCBANK, af.bankacctno, af.bankname, af.acctno cashacctno, af.bankname cibankname
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, aftype aft, mrtype mrt, sysvar sys1, sysvar sys2, sysvar sys3, SYSVAR SYS4, SYSVAR SYS5,
          sysvar sys14, sysvar sys15, sysvar sys16,sysvar sys17,
            (SELECT cfr.custid, cf.fullname
            FROM cfmast cf,
                (SELECT custid, trim(min(recustid)) recustid from cfrelation WHERE retype ='006' GROUP BY custid) cfr
            WHERE cf.custid = cfr.recustid) cfr
        WHERE CF.custid = AF.custid
            AND af.actype = aft.actype AND aft.mrtype = mrt.actype --AND mrt.mrtype IN ('S','T')
            AND cf.custid = cfr.custid (+)
                   AND sys1.grname = 'DEFINED' AND sys1.VARNAME = decode ( I_BRID ,'0001', 'VCBSREP','HCMBVSCREP')
            AND sys2.grname = 'DEFINED' AND sys2.VARNAME = decode ( I_BRID ,'0001', 'VCBSREPPOSITION','HCMBVSCREPPOSITION')
            AND sys3.grname = 'DEFINED' AND sys3.VARNAME =  decode ( I_BRID ,'0001', 'VCBSREPAUTH','HCMBVSCREPAUTH')
            AND sys14.grname = 'DEFINED' AND sys14.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSADDRESS','HCMBVSADDRESS')
            AND sys15.grname = 'DEFINED' AND sys15.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSPHONE','HCMBVSPHONE')
            AND sys16.grname = 'DEFINED' AND sys16.VARNAME =  decode (I_BRID ,'0001', 'HNBVSFAX','HCMBVSFAX')
            AND sys17.grname = 'DEFINED' AND sys17.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSTITLE','HCMBVSTITLE')
            AND sys4.grname = 'DEFINED' AND sys4.VARNAME = decode (I_BRID ,'0001', 'BVSCBANKACCT','HCMBVSCBANKACCT')
            AND sys5.grname = 'DEFINED' AND sys5.VARNAME = decode ( I_BRID ,'0001', 'BVSCBANK','HCMBVSCBANK')


            AND CF.custodycd = PV_CUSTODYCD
            AND AF.acctno = PV_AFACCTNO;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
