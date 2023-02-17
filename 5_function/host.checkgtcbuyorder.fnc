SET DEFINE OFF;
CREATE OR REPLACE FUNCTION checkgtcbuyorder(
        f_acctno IN  varchar,
        f_quantity in number,
        f_price in number,
        f_ratio in number,
        f_symbol in varchar
        )
    return number
IS
  v_Result number(30,5);
  v_acctno  varchar(20) ;
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
  v_dblTOPUP    number(20,0);
  v_groupleader varchar2(10);
  v_dblMarginRatioRate number(20,4);
  v_dblSecMarginPrice number(20,4);
  v_dblIsPPUsed number(20,4);
  v_pp  number(30,4);
  v_avllimit number(30,4);
BEGIN
    v_Result:=-1;
    v_acctno:=f_acctno;
    v_quantity:=f_quantity;
    v_price:=f_price;
    v_ratio:=f_ratio;
    v_symbol:=f_symbol;
    v_mrpricerate:=0;
    v_marginprice:=0;

    FOR i IN (SELECT MRT.MRTYPE,afT.actype,mst.groupleader,MRT.ISPPUSED,
              NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN, nvl(marginprice,0) marginprice
                        FROM AFMAST MST, AFTYPE AFT, MRTYPE MRT,
                        (SELECT r.*, s.marginprice FROM AFSERISK R, securities_info s WHERE R.codeid = s.codeid and  s.SYMBOL=v_symbol ) RSK
                        WHERE MST.ACCTNO=v_acctno
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
   LOOP
      v_margintype                     := i.mrtype;
      v_actype                         := i.actype;
      v_groupleader                    := i.groupleader;
      v_dblMarginRatioRate            := i.MRRATIOLOAN;
      v_dblSecMarginPrice             := i.MRPRICELOAN;
      v_dblIsPPUsed                   := i.ISPPUSED;
      if i.marginprice > v_dblSecMarginPrice
      then
            v_dblSecMarginPrice := v_dblSecMarginPrice;
      else
            v_dblSecMarginPrice := i.marginprice;
      end if;
      If v_dblMarginRatioRate >= 100 Or v_dblMarginRatioRate < 0
      Then
            v_dblMarginRatioRate := 0;
      END IF;
   END LOOP;
   If v_margintype in ('N','L') Then
        v_dblTOPUP     := 1;
   Else
        If v_dblIsPPUsed = 1 Then
            v_dblTOPUP     := (1 / (1 - v_dblMarginRatioRate / 100 * v_dblSecMarginPrice / v_price / 1000));
        Else
            v_dblTOPUP     := 1;
        End If;
   End If;

   if length(v_symbol)>0 then
        select nvl(rsk.mrpricerate,0) mrpricerate,nvl(rsk.mrratiorate,0) mrratiorate,sb.marginprice into v_mrpricerate,v_mrratiorate,v_marginprice from securities_info sb, (select * from afserisk where actype =v_actype) rsk where sb.codeid=rsk.codeid(+) and sb.symbol=v_symbol;
   else
        v_mrpricerate:=0;
        v_marginprice:=0;
        v_mrratiorate:=0;
   end if;

    if     v_margintype in ('N','L') then
        select
          least(balance- odamt - nvl (advamt, 0)-nvl(secureamt,0) - ramt
          - v_quantity * v_price * 1000 * v_ratio/100,
          af.advanceline + balance- odamt - nvl (advamt, 0)-nvl(secureamt,0) - ramt
          -v_quantity * v_price * 1000
          )
          into v_Result
        from cimast inner join afmast af on cimast.acctno=af.acctno
        left join
        (select * from v_getbuyorderinfo where afacctno = v_acctno) b
        on  cimast.acctno = b.afacctno
        WHERE cimast.acctno = v_acctno;
    else
        if length(v_groupleader)=0 or v_groupleader is null then
               --Tai khoan margin khong tham gia group
               SELECT
                   least(greatest(least((nvl(AF.MRCRLIMIT,0) + nvl(se.SEAMT,0)+
                                nvl(se.receivingamt,0))
                        ,nvL(AF.MRCRLIMITMAX,0)+nvl(AF.MRCRLIMIT,0)) +
                   nvl(af.advanceline,0) + balance- odamt -nvl(secureamt,0) - ramt,0)
                   - v_quantity * v_price * 1000 * v_ratio/100, --PP>=gtMua
                   nvl(af.advanceline,0) + nvl(AF.mrcrlimitmax,0) +nvl(AF.MRCRLIMIT,0)+ balance- odamt - nvl(secureamt,0) - ramt
                   - v_quantity * v_price * 1000 * v_ratio/100, --AvlLimit >= Kyquy
                   (/*nvl(af.MRCRLIMIT,0) + */  nvl(se.SEASS,0) + v_quantity* v_mrratiorate/100*least(v_marginprice,v_mrpricerate))+
                       af.mrirate/100 * (af.advanceline+balance+least(nvl(AF.MRCRLIMIT,0),nvl(secureamt,0))+ nvl(se.receivingamt,0)- odamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt-v_quantity*v_price*1000*v_ratio/100) --Rtt>=0
                   )
                   into v_Result
                   from cimast inner join afmast af on cimast.acctno=af.acctno
                   left join
                    (select * from v_getbuyorderinfo where afacctno = v_acctno) b
                    on  cimast.acctno = b.afacctno
                    LEFT JOIN
                    (select * from v_getsecmargininfo SE where se.afacctno = v_acctno) se
                    on se.afacctno=cimast.acctno
                    WHERE cimast.acctno = v_acctno;
        else
               --Tai khoan margin join theo group
               /*
               SELECT greatest(sum(least((nvl(se.MRCRLIMIT,0)
                       + nvl(se.SEAMT,0)+ nvl(se.receivingamt,0)),
                       nvL(AF.MRCRLIMITMAX,0)) +
                       balance- odamt - nvl(secureamt,0) - ramt),0) pp,
               */
               SELECT greatest(sum(least((nvl(af.MRCRLIMIT,0)
                       + nvl(se.SEAMT,0)+ nvl(se.receivingamt,0)) ,
                       nvL(AF.MRCRLIMITMAX,0)) + nvl(af.MRCRLIMIT,0) +
                       balance- odamt - nvl(secureamt,0) - ramt),0) pp,
                   greatest(sum(nvl(AF.mrcrlimitmax,0)+nvl(af.MRCRLIMIT,0) + balance- odamt - nvl(secureamt,0) - ramt),0) avllimit,
                  /* nvl(af.MRCRLIMIT,0) + */nvl(se.SEASS,0)  + v_quantity* v_mrratiorate/100*least(v_marginprice,v_mrpricerate) NAVACCOUNT,
                    balance+ least(nvl(af.mrcrlimit,0),nvl(secureamt,0))+ nvl(se.receivingamt,0)- odamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt-v_quantity*v_price*1000*v_ratio/100 OUTSTANDING
               into v_pp,v_avllimit, v_navaccount,v_outstanding
               from cimast inner join afmast af on cimast.acctno=af.acctno and af.groupleader=v_groupleader
               left join
                (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) b
                on  cimast.acctno = b.afacctno
                LEFT JOIN
                (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                on se.afacctno=cimast.acctno;

            SELECT
                least(nvl(af.advanceline,0) + v_pp
                - v_quantity * v_price * 1000 * v_ratio/100,  --PP>=gtMua
                nvl(af.advanceline,0) + v_avllimit
                - v_quantity * v_price * 1000 * v_ratio/100,--AvlLimit >= Kyquy
                v_navaccount+ af.mrirate/100 * (af.advanceline+v_outstanding) --Rtt>=0
                )
                into v_Result
               from cimast inner join afmast af on cimast.acctno=af.acctno
               left join
                (select * from v_getbuyorderinfo where afacctno = v_acctno) b
                on  cimast.acctno = b.afacctno
                LEFT JOIN
                (select * from v_getsecmargininfo SE where se.afacctno = v_acctno) se
                on se.afacctno=cimast.acctno
                WHERE cimast.acctno = v_acctno;
        end if;
    end if;
    return v_Result;
EXCEPTION
    WHEN others THEN
        return -1;
END;
 
/
