SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GET_ORDER_AVLADVANCE
(ORDERID, AFACCTNO, AAMT, DEPOAMT, PAIDAMT, 
 ADVAMT)
BEQUEATH DEFINER
AS 
(
select orderid, afacctno,aamt, (case when autoadv = 'Y' then depoamt-paidamt else 0 end)  depoamt,paidamt, depoamt advamt from (
select  sts.orderid, sts.afacctno,sum(sts.aamt) aamt,
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
    ) depoamt, fn_getdealpaid(sts.afacctno) paidamt, autoadv
from
v_order_advanceschedule sts --where AUTOADV='Y'
group by sts.orderid, sts.afacctno, autoadv)
)
/
