SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_getvoucher1108(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_POTXNUM in varchar2,pv_OBJNAME in varchar2
                                                ,pv_TLTXCD in varchar2,pv_TXDATE in varchar2,pv_TXNUM in varchar2,pv_BANKID in varchar2)
is
v_count  number;
begin
    
    OPEN PV_REFCURSOR FOR
    SELECT B.SHORTNAME BANKID, B.BANKACCTNO BANKACC, B.OWNERNAME BANKACCNAME, B.GLACCOUNT glacctno,
        CI.FEEAMT CI_FEEAMT, 
        CI.AMT CI_AMT,CI.BENEFBANK ||' - ' || CI.citybank || ' - ' || ci.cityef CI_BENEFBANK, CI.BENEFACCT CI_BENEFACCT,
        CI.BENEFCUSTNAME CI_BENEFCUSTNAME              
    FROM CIREMITTANCE CI, banknostro B WHERE CI.TXDATE = pv_TXDATE AND CI.TXNUM = pv_TXNUM
    AND B.SHORTNAME = pv_BANKID;

exception when others then
    return;
end;
 
 
 
 
 
 
 
 
 
 
 
/
