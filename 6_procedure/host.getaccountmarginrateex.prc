SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getaccountmarginrateex (
        PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
        f_acctno IN  varchar,
        f_in_date IN varchar,
        f_quantity in number,
        f_price in number,
        f_ratio in number,
        f_symbol in varchar,
        f_rmacctno in varchar default '')
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
            select 100000 MARGINRATE,10000000000000 AVLLIMIT from dual;
    else
        if length(v_groupleader)=0 or v_groupleader is null then
               --Tai khoan margin khong tham gia group
               OPEN PV_REFCURSOR FOR
                select (case when OUTSTANDING >=0 then 100000 else least(round(NAVACCOUNT/abs(OUTSTANDING),4)*100,100000) end) MARGINRATE,AVLLIMIT from
                (SELECT
                       nvl(af.MRCRLIMIT,0) + nvl(se.SEASS,0) + v_quantity* v_mrratiorate/100*least(v_marginprice,v_mrpricerate) NAVACCOUNT,
                       balance+ nvl(se.receivingamt,0)- odamt - dfdebtamt - dfintdebtamt- NVL (advamt, 0)-nvl(secureamt,0) - ramt-f_quantity*f_price*f_ratio/100 OUTSTANDING,
                       nvl(af.mrcrlimitmax,0) + balance- odamt - dfdebtamt - dfintdebtamt- nvl(secureamt,0) - ramt avllimit
               FROM cimast inner join afmast af on af.acctno = cimast.afacctno
               left join
                (select * from v_getbuyorderinfo where afacctno = v_acctno) b
                on  cimast.acctno = b.afacctno

                LEFT JOIN
                v_getsecmargininfo SE
                on se.afacctno=cimast.acctno
                WHERE cimast.acctno = v_acctno);
        else
               --Tai khoan margin join theo group
               OPEN PV_REFCURSOR FOR
                select (case when OUTSTANDING >=0 then 100000 else least(round(NAVACCOUNT/abs(OUTSTANDING),4)*100,100000) end) MARGINRATE,AVLLIMIT
                from
                (SELECT v_acctno AFACCTNO,
                           sum(nvl(af.MRCRLIMIT,0) + nvl(se.SEASS,0) ) + v_quantity* v_mrratiorate/100*least(v_marginprice,v_mrpricerate) NAVACCOUNT,
                           sum(balance+ nvl(se.receivingamt,0)- odamt- dfdebtamt - dfintdebtamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt)-f_quantity*f_price*f_ratio/100 OUTSTANDING,
                           sum(nvl(af.mrcrlimitmax,0) + balance- odamt - dfdebtamt - dfintdebtamt- nvl(secureamt,0) - ramt) avllimit
                   FROM cimast inner join afmast af on af.acctno = cimast.afacctno and af.groupleader=v_groupleader and af.acctno <> nvl(f_rmacctno,'$NULL$')
                   LEFT JOIN
                    (select b.* from v_getbuyorderinfo b,afmast af where b.afacctno = af.acctno and af.groupleader=v_groupleader) b
                    on  cimast.acctno = b.afacctno

                   LEFT JOIN
                    (select b.* from v_getsecmargininfo b,afmast af where b.afacctno = af.acctno and af.groupleader=v_groupleader) SE
                    on se.afacctno=cimast.acctno
                    group by af.groupleader
                ) A, AFMAST af WHERE A.AFACCTNO =AF.ACCTNO;
        end if;
    end if;

EXCEPTION
    WHEN others THEN
        return;
END;
 
/
