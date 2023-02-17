SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETACCOUNTAVLADVANCE_ALL
(AFACCTNO, AAMT, DEPOAMT, PAIDAMT, ADVAMT)
BEQUEATH DEFINER
AS 
(

    select afacctno,aamt, (case when autoadv = 'Y' then depoamt-paidamt else least(depoamt-paidamt,0) end)  depoamt,
    paidamt, depoamt advamt from (
    select  sts.afacctno,sum(sts.aamt) aamt,
      sum(
            greatest(
                floor(
                    least(
                        (sts.amt - exfeeamt)/(1+(sts.days*ADVRATE/100/360+sts.days*ADVBANKRATE/100/360)),
                        (sts.amt - exfeeamt)/(1+sts.days*ADVBANKRATE/100/360)-sts.ADVMINFEE,
                        (sts.amt - exfeeamt)/(1+sts.days*ADVRATE/100/360)-sts.ADVMINFEEBANK,
                        (sts.amt - exfeeamt-sts.ADVMINFEE-sts.ADVMINFEEBANK)
                    )
                )
            ,0)
        ) depoamt,sum(rightvat) rightvat, max(case when sy.varvalue='0' then 0 else nvl(grp.paidamt,0) end) paidamt, autoadv
    from
        v_advanceSchedule sts, --where AUTOADV='Y'
        (select afacctno,sum(VNDSELLDF) paidamt
            from v_getgrpdealformular
            group by afacctno
        ) grp, sysvar sy
    where sts.afacctno = grp.afacctno(+)
    and sy.grname = 'SYSTEM' and sy.varname ='HOSTATUS'
    group by sts.afacctno, autoadv)
)
/
