SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getsingleaccountmarginrate (
        PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
        f_acctno IN  varchar,
        f_in_date IN varchar,
        f_quantity number,
        f_price number,
        f_ratio number,
        f_symbol varchar)
IS
  v_Result number(18,5);
  v_acctno  varchar(20) ;
  v_in_date   date;
  v_quantity number(18,5);
  v_price number(18,5);
  v_ratio number(20,4);
  v_symbol varchar2(20);
  v_margintype char(1);
  v_actype varchar2(4);
  v_mrpricerate number(20,0);
  v_marginprice number(20,0);
  v_navaccount number(20,0);
  v_outstanding number(20,0);
  v_mrratiorate number(20,0);
  v_groupleader varchar2(10);
BEGIN
    v_acctno:=f_acctno;
    v_in_date:=to_date(f_in_date,'DD/MM/YYYY');
    v_quantity:=f_quantity;
    v_price:=f_price;
    v_ratio:=f_ratio;
    v_symbol:=f_symbol;
    v_mrpricerate:=0;
    v_marginprice:=0;
    SELECT MR.MRTYPE,af.actype,mst.groupleader into v_margintype,v_actype,v_groupleader from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=v_acctno;
    if length(v_symbol)>0 then
        select nvl(rsk.mrpricerate,0) mrpricerate,nvl(rsk.mrratiorate,0) mrratiorate,sb.marginprice into v_mrpricerate,v_mrratiorate,v_marginprice from securities_info sb, (select * from afserisk where actype =v_actype) rsk where sb.codeid=rsk.codeid(+) and sb.symbol=v_symbol;
    else
        v_mrpricerate:=0;
        v_marginprice:=0;
        v_mrratiorate:=0;
    end if;


    if     v_margintype in ('N','L') then
        OPEN PV_REFCURSOR FOR
            select 100000 MARGINRATE from dual;
    else
        OPEN PV_REFCURSOR FOR
                select (case when OUTSTANDING >=0 then 100000 else least(round(NAVACCOUNT/abs(OUTSTANDING),4)*100,100000) end) MARGINRATE,AVLLIMIT from
                (SELECT
                       nvl(af.MRCRLIMIT,0) + nvl(se.SEASS,0) + v_quantity* v_mrratiorate/100*least(v_marginprice,v_mrpricerate) NAVACCOUNT,
                       af.advanceline+balance+ nvl(adv.avladvance,0)- odamt - dfdebtamt - dfintdebtamt- NVL (advamt, 0)-nvl(secureamt,0) - ramt-f_quantity*f_price*f_ratio/100 OUTSTANDING,
                       nvl(af.mrcrlimitmax,0) + balance- odamt - nvl(secureamt,0) - ramt avllimit
               FROM cimast inner join afmast af on af.acctno = cimast.afacctno
               left join
                (select * from v_getbuyorderinfo where afacctno = v_acctno) b
                on  cimast.acctno = b.afacctno
               LEFT JOIN
                v_getsecmargininfo SE
                on se.afacctno=cimast.acctno
               LEFT JOIN
                (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt from v_getAccountAvlAdvance where afacctno = v_acctno) adv
                on adv.afacctno=cimast.acctno
                WHERE cimast.acctno = v_acctno);
    end if;

EXCEPTION
    WHEN others THEN
        return;
END;
 
/
