SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_MT_ACCOUNTS
(CITYEF, CITYBANK, AFACCTNO, TYPE, REG_TYPE, 
 EN_REG_TYPE, REG_CUSTID, REG_ACCTNO, REG_CUSTODYCD, REG_BENEFICARY_NAME, 
 REG_BENEFICARY_INFO, FEECD, FEENAME, FORP, FEEAMT, 
 FEERATE, MINVAL, MAXVAL, VATRATE, ACNIDCODE, 
 ACNIDDATE, ACNIDPLACE, CUSTODYCD, MTFRTIME, MTTOTIME, 
 TYPEMNEMONIC, EN_TYPEMNEMONIC)
BEQUEATH DEFINER
AS 
select ---rownum REFID,
     mst.cityef, mst.citybank, mst.afacctno, mst.type, mst.reg_type, mst.en_reg_type,
    mst.reg_custid, mst.reg_acctno, mst.reg_custodycd, mst.reg_beneficary_name,
    mst.reg_beneficary_info, mst.feecd, mst.feename, mst.forp, mst.feeamt, mst.feerate, mst.minval,
    mst.maxval, mst.vatrate, mst.acnidcode, mst.acniddate, mst.acnidplace,
    mst.custodycd, mst.mtfrtime, mst.MTTOTIME, mst.TYPEMNEMONIC, MST.EN_TYPEMNEMONIC
from
(
select MST.Cityef, MST.Citybank, afm.acctno AFACCTNO, MST.TYPE,
    (CASE WHEN MST.TYPE=1 THEN 'Ben ngoai' WHEN MST.TYPE=2 THEN 'VCB' ELSE 'Noi bo' END) REG_TYPE,
    (CASE WHEN MST.TYPE=1 THEN 'External' WHEN MST.TYPE=2 THEN 'VCB' ELSE 'Internal' END) EN_REG_TYPE,
    ---(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.CUSTID ELSE AF.CUSTID END) REG_CUSTID,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.CUSTID ELSE cf.CUSTID END) REG_CUSTID,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.BANKACC ELSE MST.CIACCOUNT END) REG_ACCTNO,
    ---(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN '' ELSE AF.CUSTODYCD END) REG_CUSTODYCD,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN '' ELSE cf.CUSTODYCD END) REG_CUSTODYCD,
    ---(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.BANKACNAME ELSE TO_CHAR(AF.FULLNAME) END) REG_BENEFICARY_NAME,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.BANKACNAME ELSE TO_CHAR(cf.FULLNAME) END) REG_BENEFICARY_NAME,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.BANKNAME ELSE 'VCB' END) REG_BENEFICARY_INFO,
    FDEF.FEECD, FDEF.FEENAME, FDEF.FORP, FDEF.FEEAMT, FDEF.FEERATE, FDEF.MINVAL, FDEF.MAXVAL, FDEF.VATRATE,
    ----(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acnidcode ELSE to_char(AF.idcode) END) acnidcode,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acnidcode ELSE to_char(cf.idcode) END) acnidcode,
    ---(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acniddate ELSE AF.iddate END) acniddate,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acniddate ELSE cf.iddate END) acniddate,
    ---(CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acnidplace ELSE to_char(AF.idplace) END) acnidplace,
    (CASE WHEN MST.TYPE=1 OR MST.TYPE=2 THEN MST.acnidplace ELSE to_char(cf.idplace) END) acnidplace,
    cf.custodycd, var1.VARVALUE MTFRTIME, var2.VARVALUE MTTOTIME, /*af.TYPEMNEMONIC*/ null TYPEMNEMONIC,null  EN_TYPEMNEMONIC
FROM CFOTHERACC MST,
    /*(select cf.*, af.acctno, typ.MNEMONIC TYPEMNEMONIC from cfmast cf, afmast af, aftype typ where cf.custid = af.custid AND af.actype = typ.actype) AF,*/
    FEEMASTER FDEF , afmast afm, cfmast cf, sysvar var1, sysvar var2
WHERE /*MST.ciaccount = AF.acctno (+) AND*/ MST.FEECD=FDEF.FEECD (+)
    AND afm.custid = mst.cfcustid AND cf.custid = afm.custid
    ---and afm.acctno <> nvl(MST.CIACCOUNT,'A')
and var1.grname = 'STRADE' and var1.varname = 'MT_FRTIME'
and var2.grname = 'STRADE' and var2.varname = 'MT_TOTIME'
AND NVL(MST.CHSTATUS,'C') <> 'A'
and MST.TYPE <> 0 --- khong lay chuyen khoan noi bo
union all
select null cityef, NULL  citybank, AF2.acctno afacctno, '0' type, 'Noi bo' reg_type, 'Internal' en_reg_type,
    AF1.custid reg_custid, af1.acctno reg_acctno, Cf.custodycd reg_custodycd, Cf.fullname reg_beneficary_name,
    'VCB' reg_beneficary_info, NULL feecd, nULL feename, nULL forp, nULL feeamt, nULL feerate, null minval,
    null maxval, null vatrate, Cf.idcode acnidcode, Cf.iddate acniddate, Cf.idplace acnidplace,
    Cf.custodycd custodycd, var1.VARVALUE MTFRTIME, var2.VARVALUE MTTOTIME, a1.cdcontent TYPEMNEMONIC , a1.en_cdcontent EN_TYPEMNEMONIC
from AFMAST AF1, afmast AF2, cfmast cf, aftype typ,
    sysvar var1, sysvar var2, allcode a1
where CF.CUSTID = af1.CUSTID AND CF.CUSTID = af2.CUSTID
    and AF1.acctno <> af2.acctno AND af1.status = 'A'
    AND af2.status = 'A' and af1.actype = typ.actype
    and var1.grname = 'STRADE' and var1.varname = 'MT_FRTIME'
    and var2.grname = 'STRADE' and var2.varname = 'MT_TOTIME'
    AND TYP.PRODUCTTYPE = A1.CDVAL AND A1.CDNAME = 'PRODUCTTYPE'  AND CDTYPE = 'CF'

/*select null cityef, NULL  citybank, mst.acctno afacctno, '0' type, 'Noi bo' reg_type, 'Internal' en_reg_type,
    mst.custid reg_custid, af.acctno reg_acctno, af.custodycd reg_custodycd, af.fullname reg_beneficary_name,
    'VCB' reg_beneficary_info, NULL feecd, nULL feename, nULL forp, nULL feeamt, nULL feerate, null minval,
    null maxval, null vatrate, af.idcode acnidcode, af.iddate acniddate, af.idplace acnidplace,
    af.custodycd custodycd, var1.VARVALUE MTFRTIME, var2.VARVALUE MTTOTIME, af.TYPEMNEMONIC
from
(
    select cf.custodycd, af.acctno, cf.custid
    from afmast af, cfmast cf
    where af.custid = cf.custid and af.status = 'A'
) mst,
(
    select cf.custodycd, af.acctno, af.custid, cf.fullname, cf.idcode, cf.iddate, cf.idplace, typ.mnemonic TYPEMNEMONIC
    from afmast af, cfmast cf, aftype typ
    where af.custid = cf.custid and af.status = 'A' and af.actype = typ.actype
) af, sysvar var1, sysvar var2
where mst.custodycd = af.custodycd and mst.acctno <> af.acctno
    and var1.grname = 'STRADE' and var1.varname = 'MT_FRTIME'
    and var2.grname = 'STRADE' and var2.varname = 'MT_TOTIME'*/
/*union
select ls.regional cityef, ls.regional  citybank, af.acctno afacctno, '1' type, 'Noi bo' reg_type, 'Internal' en_reg_type,
    af.custid reg_custid, af.bankacctno reg_acctno, cf.custodycd reg_custodycd, cf.fullname reg_beneficary_name,
    ls.bankname reg_beneficary_info, NULL feecd, nULL feename, nULL forp, nULL feeamt, nULL feerate, null minval,
    null maxval, null vatrate, cf.idcode acnidcode, cf.iddate acniddate, cf.idplace acnidplace,
    cf.custodycd custodycd, var1.VARVALUE MTFRTIME, var2.VARVALUE MTTOTIME, aft.mnemonic mnemonic
from afmast af , cfmast cf, aftype aft, sysvar var1, sysvar var2, crbbanklist ls, crbbankmap map
where af.corebank = 'N' and af.custid = cf.custid
    and af.alternateacct = 'Y' and af.actype = aft.actype
    and ls.bankcode= map.bankcode and map.bankid= substr(af.bankacctno,1,3)
    and var1.grname = 'STRADE' and var1.varname = 'MT_FRTIME'
    and var2.grname = 'STRADE' and var2.varname = 'MT_TOTIME'*/
)mst
/
