SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SS_LNMAST
(GOC_FLEX, LAIMAGIN_FLEX, GOC_SBS, LAI_SBS, LECH_GOC, 
 LECH_LAI)
BEQUEATH DEFINER
AS 
SELECT flex.goc_flex,flex.laimagin_flex ,sbs.goc_sbs,sbs.lai_sbs , flex.goc_FLEX-sbs.goc_SBS LECH_GOC,flex.laimagin_FLEX-sbs.lai_SBS LECH_LAI FROM 
(SELECT  CF.CUSTODYCD||CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END DESCRIPTION_flex,
 ln.PRINNML +ln.prinovd goc_flex, intnmlacr+intdue +intnmlovd + intovdacr laimagin_flex ,  oprinnml +oprinovd goct0
 , ointnmlacr + ointnmlovd + ointovdacr + ointdue  lait0
FROM lnmast ln, afmast af , aftype, cfmast cf
WHERE ln.trfacctno = af.acctno
AND af.actype = aftype.actype
AND cf.custid =af.custid) flex,
(
SELECT custodycd||accounttype DESCRIPTION, sum( prinml) goc_sbs, sum(intnmlacr) lai_sbs   FROM lnmastcv 
GROUP BY  custodycd,accounttype
)sbs
WHERE sbs.DESCRIPTION =flex.DESCRIPTION_flex(+)
AND ( nvl (flex.goc_flex,0)<> nvl(sbs.goc_sbs,0) OR nvl (flex.laimagin_flex,0)<> nvl(sbs.lai_sbs,0))
UNION 
SELECT flex.goc_flex,flex.laimagin_flex ,sbs.goc_sbs,sbs.lai_sbs , flex.goc_FLEX-sbs.goc_SBS LECH_GOC,flex.laimagin_FLEX-sbs.lai_SBS LECH_LAI FROM 
(SELECT  CF.CUSTODYCD||CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END DESCRIPTION_flex,
 ln.PRINNML +ln.prinovd goc_flex, intnmlacr+intdue +intnmlovd + intovdacr laimagin_flex ,  oprinnml +oprinovd goct0
 , ointnmlacr + ointnmlovd + ointovdacr + ointdue  lait0
FROM lnmast ln, afmast af , aftype, cfmast cf
WHERE ln.trfacctno = af.acctno
AND af.actype = aftype.actype
AND cf.custid =af.custid) flex,
(
SELECT custodycd||accounttype DESCRIPTION, sum( prinml) goc_sbs, sum(intnmlacr) lai_sbs   FROM lnmastcv 
GROUP BY  custodycd,accounttype
)sbs
WHERE flex.DESCRIPTION_flex=sbs.DESCRIPTION (+)
AND ( nvl (flex.goc_flex,0)<> nvl(sbs.goc_sbs,0) OR nvl (flex.laimagin_flex,0)<> nvl(sbs.lai_sbs,0))
/
