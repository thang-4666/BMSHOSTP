SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETACCOUNTAVLADVANCE
(AFACCTNO, AAMT, DEPOAMT, PAIDAMT, ADVAMT, 
 RCVAMT, ADVPRIO)
BEQUEATH DEFINER
AS 
(

    select afacctno,aamt, (case when autoadv = 'Y' then depoamt-paidamt else least(depoamt-paidamt,0) end)  depoamt,
    paidamt, depoamt advamt,rcvamt,ADVPRIO from (
    select  sts.afacctno,sum(sts.aamt) aamt,
        /*least(
            greatest(sum(floor((sts.amt - exfeeamt)*(1-(sts.days*ADVRATE/100/360+sts.days*ADVBANKRATE/100/360)))),0),
            greatest(sum(floor(sts.amt - exfeeamt)) - max (sts.ADVMINFEE) - max(sts.ADVMINFEEBANK),0)
        ) depoamt,*/
         least(
            greatest(sum(floor((sts.amt - exfeeamt)/(1+(sts.days*ADVRATE/100/360+sts.days*ADVBANKRATE/100/360)))),0),
            greatest(sum(floor(sts.amt - exfeeamt)) - max (sts.ADVMINFEE) - max(sts.ADVMINFEEBANK),0)
        ) depoamt,
        sum(rightvat) rightvat,
        max(case when sy.varvalue='0' then 0 else fn_getdealgrppaid(sts.afacctno) end) paidamt, autoadv,
        sum(sts.amt+sts.aamt - exfeeamt) rcvamt,MAX(STS.ADVPRIO) ADVPRIO
    from
        v_advanceSchedule sts, --where AUTOADV='Y'
        sysvar sy
    where sy.grname = 'SYSTEM' and sy.varname ='HOSTATUS'
    group by sts.afacctno, autoadv)
)
/
