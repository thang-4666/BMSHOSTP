SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ODMAST_RE
(MONTHORDER, BRANCHCODE, CUSTODYCD, OPENDATE, TRADECODE, 
 MARGINTYPE, CUSTOMERTYPE, DOMESTICFOREIGN, GRPNAME, TYPESYMBOL, 
 AMOUNT, FEEACR, TYPE_GROUP, RE_GROUP, RE_USER, 
 LEADER, CAREBY, RE_TYPENAME, RE_GROUP2, RE_GROUP3, 
 RD_TRUONGNHOM, RD_USER, RD_TYPENAME)
BEQUEATH DEFINER
AS 
SELECT  ThangThongKe MonthOrder ,BranchCode,CustomerId custodycd ,OpenDate,TradeCode,MarginType,CustomerType,DomesticForeign,grpname,typesymbol,
sum(amount)amount, sum(feeacr)feeacr, type_group, re_group,re_user, truongnhom leader,careby,re_typename, re_group2, re_group3, rd_truongnhom, rd_user, rd_typename
FROM
(SELECT to_char(od.txdate,'mm/yyyy') ThangThongKe,re.brid BranchCode,cf.custodycd CustomerId,cf.opndate OpenDate,
DECODE ( od.via,'T','CALL','O','ONLINE','M','MOBILE','H','HOME','F','SAN') TradeCode,
aftype.mnemonic MarginType,cf.custtype CustomerType, decode ( cf.country,'234','trong nuoc','nuoc ngoai') DomesticForeign,
tl.grpname, case when  sb.sectype ='001' then 'co phieu' when  sb.sectype in ('003','006') then 'trai phieu' when  sb.sectype in ('008') then 'chung chi quy' end typesymbol
 ,max(od.execamt)   amount, max( od.feeacr)   feeacr, tl.description type_group,
max( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.truongnhom  ELSE '' end) truongnhom ,
max(CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.regroup1  ELSE '' end) re_group,
max(CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.regroup2  ELSE '' end) re_group2,
max(CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.regroup3  ELSE '' end) re_group3,
max( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.reuser  ELSE '' end) re_user,
max( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.typename  ELSE '' end) re_typename,
cf.careby,
max( CASE WHEN od.txdate >= rd_frdate AND od.txdate <= rd_todate AND  od.txdate >= rdgl_frdate AND od.txdate <= rdgl_todate THEN rd.truongnhom  ELSE '' end) rd_truongnhom,
max( CASE WHEN od.txdate >= rd_frdate AND od.txdate <= rd_todate AND  od.txdate >= rdgl_frdate AND od.txdate <= rdgl_todate THEN rd.reuser  ELSE '' end) rd_user,
max( CASE WHEN od.txdate >= rd_frdate AND od.txdate <= rd_todate AND  od.txdate >= rdgl_frdate AND od.txdate <= rdgl_todate THEN rd.typename  ELSE '' end) rd_typename
FROM vw_odmast_all od,cfmast cf,afmast af,aftype,tlgroups TL,sbsecurities sb,
    (SELECT substr(re.afacctno,1,4) brid,  re.afacctno , REGl.refrecflnkid, cfre.fullname reuser,
       re.frdate re_frdate, nvl(re.clstxdate-1, re.todate) re_todate ,
       REGl.frdate REGl_frdate, nvl(REGl.clstxdate-1, REGl.todate) REGl_todate,cftn.fullname truongnhom, retype.typename,
       g1.FULLNAME regroup1, g2.fullname regroup2, g3.fullname regroup3
    FROM reaflnk re, regrplnk REGl, retype, cfmast cf,regrp g1 , cfmast cfre, cfmast cftn , regrp g2, regrp g3
    WHERE re.reacctno = REGl.reacctno(+)
    AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
    AND retype.rerole ='RM'
    AND re.afacctno = cf.custid
    AND REGl.refrecflnkid = g1.autoid(+)
    AND substr(re.reacctno,1,10)= cfre.custid
    and g1.custid = cftn.custid
    and g1.prgrpid = g2.autoid(+)
    and g2.prgrpid = g3.autoid(+)
    )RE,
    (
    SELECT substr(re.afacctno,1,4) brid,  re.afacctno , REGl.refrecflnkid, cfre.fullname reuser,
       re.frdate rd_frdate, nvl(re.clstxdate-1, re.todate) rd_todate ,
       REGl.frdate RdGl_frdate, nvl(REGl.clstxdate-1, REGl.todate) RdGl_todate, cftn.fullname truongnhom, retype.typename
    FROM reaflnk re, regrplnk REGl, retype, cfmast cf, regrp g1 , cfmast cfre, cfmast cftn
    WHERE re.reacctno = REGl.reacctno(+)
    AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
    AND retype.rerole = 'RD'
    AND re.afacctno = cf.custid
    AND REGl.refrecflnkid = g1.autoid(+)
    AND substr(re.reacctno,1,10)= cfre.custid
    and g1.custid = cftn.custid
    )RD
WHERE od.afacctno =af.acctno
AND af.custid = cf.custid
AND af.actype =aftype.actype
AND cf.careby = tl.grpid
and od.codeid = sb.codeid
AND od.execamt >0
AND  od.txdate >='01-jan-2014'
AND CF.custid = re.afacctno (+)
AND CF.custid = rd.afacctno (+)
GROUP BY od.orderid, od.txdate,re.brid,cf.custodycd, cf.opndate,od.via,aftype.mnemonic,cf.custtype ,cf.country,
tl.grpname,sb.sectype,tl.description,CF.CAREBY
)
GROUP BY ThangThongKe ,BranchCode,CustomerId,OpenDate,TradeCode,MarginType,CustomerType,DomesticForeign,grpname,typesymbol, type_group,re_group,re_user,truongnhom,careby,RE_TYPENAME,
 re_group2, re_group3, rd_truongnhom, rd_user, rd_typename
ORDER BY thangthongke,customerid
/
