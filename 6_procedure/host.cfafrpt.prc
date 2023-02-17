SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CFAFRPT" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_CFCUSTID       IN       VARCHAR2
)
IS



--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
l_empty varchar2(50);
l_cfotheracc varchar2(1000);
l_bank varchar2(100);
l_cfotheracccount number;
BEGIN
l_empty:= '................................'; -- gia tri rong khi ko co gia tri
l_cfotheracccount:= 0;
for rec in
(
select cf.* from cfotheracc cf where type = '1' and cf.cfcustid = p_CFCUSTID
)
loop
    l_cfotheracccount:= l_cfotheracccount + 1;
    l_cfotheracc:= l_cfotheracc || rec.bankacname || '|' || rec.bankacc || '|' || rec.bankname || '|' || rec.citybank || '$';
    l_bank:=rec.bankacc;
end loop;
loop
    if l_cfotheracccount >= 5 then
        exit;
    end if;
    l_cfotheracccount:= l_cfotheracccount + 1;
    l_cfotheracc:= l_cfotheracc || l_empty || '|' || l_empty || '|' || l_empty || '|' || l_empty || '$';
end loop;

OPEN PV_REFCURSOR
    FOR
    select  cf.custid,A1.cdcontent country, cft.typename typename,
            nvl(cf.fullname,l_empty) fullname, nvl(to_char(cf.dateofbirth,'DD/MM/RRRR'),l_empty) dateofbirth,
            nvl(cf.idcode,l_empty) idcode, nvl(to_char(cf.iddate,'DD/MM/RRRR'),l_empty) iddate, nvl(cf.idplace,l_empty) idplace, nvl(cf.address,l_empty) address,
            nvl(cf.mobile,l_empty) mobile, nvl(cf.mobilesms,l_empty) mobilesms, nvl(cf.fax,l_empty) fax,
            nvl(cf.email,l_empty) email, cf.custodycd, nvl(cf.taxcode,l_empty) taxcode,
            nvl(cf.pin,l_empty) pin, nvl(cf.username,l_empty) username, nvl(cf.tradingcode,l_empty) tradingcode, nvl(to_char(cf.tradingcodedt,'DD/MM/RRRR'),l_empty) tradingcodedt,
            nvl(to_char(cf.opndate,'DD/MM/RRRR'),l_empty) opndate,
            decode(cf.tradefloor,'Y','X','') tradefloor,
            decode(cf.tradetelephone,'Y','X','') tradetelephone,
            decode(ot.cfcustid,null,'','X') tradeonline,
            --decode(cf.tradeonline,'Y','X','') tradeonline,
            max(af.acctno) afacctno,
            max(nvl(af.bankacctno,l_empty)) afbankacctno,
            max(decode(af.bankname,'---',l_empty,af.cdcontent)) afbankname,
            max(af.opndate) afopndate, max(decode(af.corebank,'Y','X','')) afcorebank,
            max(decode(af.autoadv,'Y','X','')) afautoadv,
            nvl(cfa.cfafullname,l_empty) cfafullname,nvl(cfa.cfaaddress,l_empty) cfaaddress,
            nvl(cfa.cfamobilesms,l_empty) cfamobilesms,nvl(cfa.cfaidcode,l_empty) cfaidcode,
            nvl(to_char(cfa.valdate,'DD/MM/RRRR'),l_empty) valdate,
            nvl(to_char(cfa.expdate,'DD/MM/RRRR'),l_empty) expdate,
            nvl(cfa.cfaidplace,l_empty) cfaidplace,
            nvl(to_char(cfa.cfaiddate,'DD/MM/RRRR'),l_empty) cfaiddate,
            nvl(cfa.cfamobile,l_empty) cfamobile,nvl(cfa.cfaemail,l_empty) cfaemail,
            nvl(cfrm.fullname,l_empty) cfrmfullname, --nvl(cfrm.address,l_empty) cfrmaddress,
            nvl(cfrm.licenseno,l_empty) cfrmidcode,
            --nvl(to_char(cfrm.lniddate,'DD/MM/RRRR'),l_empty) cfrmiddate,
            --nvl(cfrm.lnplace,l_empty) cfrmidplace, nvl(cfrm.mobile,l_empty) cfrmmobile, nvl(cfrm.telephone,l_empty) cfrmmobilesms,
            --nvl(cfrm.email,l_empty) cfrmemail,
            nvl(cfrm.description,l_empty) cfrmdescription,
            nvl(cfra.fullname,l_empty) cfrafullname, nvl(cfra.address,l_empty) cfraaddress, nvl(cfra.idcode,l_empty) cfraidcode,
            nvl(to_char(cfra.iddate,'DD/MM/RRRR'),l_empty) cfraiddate, nvl(cfra.idplace,l_empty) cfraidplace,
            nvl(cfra.mobile,l_empty) cframobile, nvl(cfra.mobilesms,l_empty) cframobilesms, nvl(cfra.email,l_empty) cfraemail,
            nvl(cfra.description,l_empty) cfradescription,
            decode(ot.authtype,'0','X','') bypass,
            decode(ot.authtype,'1','X','') bytoken,
            decode(ot.authtype,'2','X','') bymatrix,
            decode(ot.authtype,'1',serialtoken,l_empty) serialtokenbytoken,
            decode(ot.authtype,'2',serialtoken,l_empty) serialtokenbymatrix,
            decode(l_cfotheracc,null,'','X') transferonline,
            l_cfotheracc cfotheracc, l_bank bank_VCB--,
    from cfmast cf,(select cdval,cdcontent from allcode where cdname = 'COUNTRY') A1,cftype cft,
        (
            select af.*, c1.cdcontent
            from afmast af, aftype aft, mrtype mrt , ALLCODE c1
            where  C1.cdtype = 'CF' and c1.cdname = 'BANKNAME' and c1.cdval = af.bankname
                and af.actype = aft.actype and aft.mrtype = mrt.actype
        ) af,
---            aftype aft, mrtype mrt,
        (select cfa.* from (
                select cfa.cfcustid, decode(cfa.custid,null,cfa.fullname,cf2.fullname) cfafullname,
                decode(cfa.custid,null,cfa.address,cf2.address) cfaaddress,
                decode(cfa.custid,null,cfa.telephone,cf2.mobilesms) cfamobilesms,
                decode(cfa.custid,null,cfa.licenseno,cf2.idcode) cfaidcode,
                cfa.valdate, cfa.expdate,
                decode(cfa.custid,null,cfa.lnplace,cf2.idplace) cfaidplace,
                decode(cfa.custid,null,cfa.lniddate,cf2.iddate) cfaiddate,
                decode(cfa.custid,null,null,cf2.mobile) cfamobile,
                decode(cfa.custid,null,null,cf2.email) cfaemail
                from afmast af, cfauth cfa, cfmast cf2
                where af.custid = cfa.cfcustid and cfa.custid = cf2.custid(+)
                and deltd <> 'Y' and af.opndate between cfa.valdate and cfa.expdate
                order by cfa.autoid) cfa where rownum = 1) cfa,
        (
            /*select trim(cfr.custid) custid,
                (CASE WHEN cf.fullname IS NULL THEN cfr.fullname ELSE cf.fullname END) fullname,
                (CASE WHEN cf.address IS NULL THEN cfr.address ELSE cf.address END) address,
                (CASE WHEN cf.idcode IS NULL THEN cfr.licenseno ELSE cf.idcode END) licenseno,
                (CASE WHEN cf.iddate IS NULL THEN cfr.lniddate ELSE cf.iddate END) lniddate,
                (CASE WHEN cf.idplace IS NULL THEN cfr.lnplace ELSE cf.idplace END) lnplace,
                (CASE WHEN cf.mobilesms IS NULL THEN cfr.telephone ELSE cf.mobilesms END) mobile,
                cf.mobile telephone, cf.email, cfr.description
            from afmast af, cfrelation cfr, cfmast cf
            where trim(cfr.custid) = af.custid(+)
                and trim(cfr.recustid) = cf.custid(+) ---and cfr.custid = p_CFCUSTID
                and cfr.retype = '010' and cfr.actives ='Y'*/
            SELECT trim(CFR.CUSTID) custid,CFR.FULLNAME fullname,CFR.LICENSENO licenseno,RET.DISPLAY description FROM CFRELATION CFR,
                (SELECT  CDVAL VALUECD, CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = 'CF' AND CDNAME = 'RETYPE') RET
            WHERE CFR.RETYPE = RET.VALUE
            and trim(CFR.CUSTID) = p_CFCUSTID
        ) cfrm,
        (select trim(cfr.custid) custid, cfr.fullname, cfr.address, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.mobilesms, cf.email, cfr.description
                from afmast af, cfrelation cfr, cfmast cf
                where trim(cfr.custid) = af.custid(+) and trim(cfr.recustid) = cf.custid(+) and trim(cfr.custid) = p_CFCUSTID and cfr.retype = '009' and cfr.actives ='Y') cfra,
        (select * from afmast af, otright ot where af.custid = ot.cfcustid and ot.deltd <> 'Y' ) ot

    where cf.custid = af.custid(+)
---    and af.actype = aft.actype and aft.mrtype = mrt.actype
    and cf.custid = cfa.cfcustid(+)
    and cf.custid = cfrm.custid(+)
    and cf.custid = cfra.custid(+)
    and cf.custid = ot.custid(+)
    and cf.country = A1.cdval(+)
    and cf.actype = cft.actype
---    and C1.cdtype = 'CF' and c1.cdname = 'BANKNAME' and c1.cdval = af.bankname
    and cf.custid = p_CFCUSTID
group by cf.custid,cft.typename,
            nvl(cf.fullname,l_empty) , nvl(to_char(cf.dateofbirth,'DD/MM/RRRR'),l_empty) ,
            nvl(cf.idcode,l_empty) , nvl(to_char(cf.iddate,'DD/MM/RRRR'),l_empty) ,
            nvl(cf.idplace,l_empty) , nvl(cf.address,l_empty) ,
            nvl(cf.mobile,l_empty) , nvl(cf.mobilesms,l_empty) , nvl(cf.fax,l_empty) ,
            nvl(cf.email,l_empty) , cf.custodycd, nvl(cf.taxcode,l_empty) ,
            nvl(cf.pin,l_empty) , nvl(cf.username,l_empty) , nvl(cf.tradingcode,l_empty) ,
            nvl(to_char(cf.tradingcodedt,'DD/MM/RRRR'),l_empty) ,
            nvl(to_char(cf.opndate,'DD/MM/RRRR'),l_empty) ,
            decode(cf.tradefloor,'Y','X','') ,
            decode(cf.tradetelephone,'Y','X','') ,
            decode(ot.cfcustid,null,'','X') ,
            --decode(cf.tradeonline,'Y','X','') tradeonline,
            nvl(cfa.cfafullname,l_empty) ,nvl(cfa.cfaaddress,l_empty) ,
            nvl(cfa.cfamobilesms,l_empty) ,nvl(cfa.cfaidcode,l_empty) ,
            nvl(to_char(cfa.valdate,'DD/MM/RRRR'),l_empty) ,
            nvl(to_char(cfa.expdate,'DD/MM/RRRR'),l_empty) ,
            nvl(cfa.cfaidplace,l_empty) ,
            nvl(to_char(cfa.cfaiddate,'DD/MM/RRRR'),l_empty) ,
            nvl(cfa.cfamobile,l_empty) ,nvl(cfa.cfaemail,l_empty) ,
            nvl(cfrm.fullname,l_empty) , --nvl(cfrm.address,l_empty) ,
            nvl(cfrm.licenseno,l_empty) ,
            --nvl(to_char(cfrm.lniddate,'DD/MM/RRRR'),l_empty) ,
            --nvl(cfrm.lnplace,l_empty) , nvl(cfrm.mobile,l_empty) , nvl(cfrm.telephone,l_empty) ,
            --nvl(cfrm.email,l_empty) ,
            nvl(cfrm.description,l_empty) ,
            nvl(cfra.fullname,l_empty) , nvl(cfra.address,l_empty) , nvl(cfra.idcode,l_empty) ,
            nvl(to_char(cfra.iddate,'DD/MM/RRRR'),l_empty) , nvl(cfra.idplace,l_empty) ,
            nvl(cfra.mobile,l_empty) , nvl(cfra.mobilesms,l_empty) , nvl(cfra.email,l_empty) ,
            nvl(cfra.description,l_empty) ,
            decode(ot.authtype,'0','X','') ,
            decode(ot.authtype,'1','X','') ,
            decode(ot.authtype,'2','X','') ,
            decode(ot.authtype,'1',serialtoken,l_empty) ,
            decode(ot.authtype,'2',serialtoken,l_empty) ,
            decode(l_cfotheracc,null,'','X') ,
            l_cfotheracc,l_bank,A1.cdcontent
    ;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
