SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1014" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   PV_BANKID      IN       VARCHAR2,
    I_BRID           IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO IN HOP DONG MO TIEU KHOAN GIAO DICH KY QUY
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- ThanhNM   11-JUN-2012    CREATED
-- QuyetKD   14-JUN-2012    MODIFY
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_CUSTBANK          varchar2(10);
    V_SVTYPE            VARCHAR2(5);
    V_IN_DATE           VARCHAR2(15);
    V_SIGNTYPE          VARCHAR2(10);
    V_BRID              VARCHAR2(4);


BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := pv_BRID;


     OPEN PV_REFCURSOR FOR

     SELECT
            -- Thong tin khach hang---------------------------------
            CF.custid, CF.custodycd, AF.acctno, cf.fullname, to_char(cf.dateofbirth,'DD/mm/yyyy') dateofbirth,
            cf.idcode, to_char(cf.iddate,'dd/mm/yyyy') iddate,
            cf.idplace,
            cf.address,
            nvl(cf.email,'.........................') email ,
            nvl(cf.mobile,cf.phone) phone ,
            nvl(cf.fax,  '.........................') fax ,

            -- Thong tin Cong cy chung khoan -------------------------
            sys1.varvalue BVSCREP,
            sys2.varvalue BVSCREPPOSITION,
            sys3.varvalue BVSCREPAUTH,
            sys4.varvalue BVSADDRESS
            , sys5.varvalue BVSPHONE
            , sys6.varvalue BVSFAX
            , sys7.varvalue BVSTITLE,
            -- Thong tin ngan hang------------------------------------
            nvl(cf2.fullname,'.........................') b_fullname,
            nvl(cf2.address,'.........................') b_address,
            nvl(cf2.mobile,cf2.phone) b_phone,
            nvl(cf2.fax,'.........................') b_fax,
            nvl(a1.CDCONTENT,'.........................') B_Ky_hieu,
            nvl(a2.CDCONTENT,'.........................') B_nguoi_dai_dien,
            nvl(a3.CDCONTENT,'.........................') B_chuc_vu,
            nvl(a4.CDCONTENT,'.........................') B_Giay_uy_quyen


        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, sysvar sys1, sysvar sys2, sysvar sys3,
         sysvar sys4, sysvar sys5, sysvar sys6,sysvar sys7,
                (SELECT cfr.custid, cf.fullname, cf.idcode, cf.iddate, cf.idplace
                 FROM cfmast cf,
                (SELECT trim(custid) custid, trim(min(recustid)) recustid from cfrelation WHERE retype ='006' GROUP BY custid) cfr
                 WHERE cf.custid = cfr.recustid
                 )cfr,
                 (
                 select * from cfmast where custid =  PV_BANKID
                 ) cf2,
                 Allcode a1 ,Allcode a2 , Allcode a3, Allcode a4
        WHERE CF.custid = AF.custid
            AND cf.custid = cfr.custid (+)
                      AND sys1.grname = 'DEFINED' AND sys1.VARNAME = decode ( I_BRID ,'0001', 'VCBSREP','HCMBVSCREP')
            AND sys2.grname = 'DEFINED' AND sys2.VARNAME = decode ( I_BRID ,'0001', 'VCBSREPPOSITION','HCMBVSCREPPOSITION')
            AND sys3.grname = 'DEFINED' AND sys3.VARNAME =  decode ( I_BRID ,'0001', 'VCBSREPAUTH','HCMBVSCREPAUTH')
            AND sys4.grname = 'DEFINED' AND sys4.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSADDRESS','HCMBVSADDRESS')
            AND sys5.grname = 'DEFINED' AND sys5.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSPHONE','HCMBVSPHONE')
            AND sys6.grname = 'DEFINED' AND sys6.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSFAX','HCMBVSFAX')
            AND sys7.grname = 'DEFINED' AND sys7.VARNAME =  decode ( I_BRID ,'0001', 'HNBVSTITLE','HCMBVSTITLE')


            AND a1.CDNAME =PV_BANKID  and a1.CDVAL= 'Bank_info'
            AND a2.CDNAME =PV_BANKID  and a2.CDVAL= 'Nguoi_dai_dien'
            AND a3.CDNAME =PV_BANKID  and a3.CDVAL= 'Chuc_vu'
            AND a4.CDNAME =PV_BANKID  and a4.CDVAL= 'Giay_uy_quyen_so'

            AND CF.custodycd  = PV_CUSTODYCD
            AND AF.acctno  = PV_AFACCTNO;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
