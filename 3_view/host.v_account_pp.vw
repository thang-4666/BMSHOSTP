SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ACCOUNT_PP
(ACCTNO, PP)
BEQUEATH DEFINER
AS 
SELECT      af.acctno,
                        case when mr.MRTYPE in ('N','L') then
                            greatest(nvl(adv.avladvance,0) + af.advanceline + balance- odamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt,0)
                        when mr.MRTYPE in ('S','T') then
                            greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(secinfo.SEAMT,0)+nvl(secinfo.receivingamt,0)),
                            nvl(adv.avladvance,0) + greatest(nvL(AF.MRCRLIMITMAX,0)+nvl(AF.MRCRLIMIT,0)-dfodamt,0)) + nvl(af.advanceline,0) + balance- odamt -nvl(secureamt,0) - ramt,0)
                        else
                            greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(secinfo.SEAMT,0)+ nvl(secinfo.receivingamt,0)),
                            nvl(adv.avladvance,0) + greatest(nvL(AF.MRCRLIMITMAX,0)+nvl(AF.MRCRLIMIT,0)-dfodamt,0)) + nvl(af.advanceline,0) + balance- odamt -nvl(secureamt,0) - ramt,0)
                        end pp
            FROM        cimast mst, afmast af, sbcurrency ccy, v_getbuyorderinfo buyinfo, v_getsecmargininfo secinfo,
                        (select     sum(depoamt) avladvance,afacctno
                        from        v_getAccountAvlAdvance
                        group by    afacctno) adv,
                        mrtype mr, aftype aftype
            where       af.acctno = mst.afacctno
                        and aftype.mrtype = mr.actype
                        and aftype.actype = af.actype
                        and ccy.ccycd = mst.ccycd
                        and mst.acctno = buyinfo.afacctno(+)
                        and mst.acctno = secinfo.afacctno(+)
                        and mst.acctno = adv.afacctno(+)
/
