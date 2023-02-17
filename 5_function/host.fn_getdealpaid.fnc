SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdealpaid(fv_acctno in varchar2)
  RETURN number IS
  v_Result number;
  v_values number;
  v_overdfqtty number;
  v_dfrlsqtty number;
  v_dfqtty number;
  v_strCURRDATE date;
  v_hostatus varchar2(10);
BEGIN
    SELECT TO_DATE (varvalue, 'DD/MM/RRRR')
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT varvalue
               INTO v_hostatus
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'HOSTATUS';
    v_Result:=0;
    --Neu dong cua hoi so thi khong tinh no.
    if v_hostatus ='0' THEN
        return v_Result;
    end if;
    --Lay khoan no cho cac lenh ban deal
    begin
        select
        sum(greatest(round(least((sts.qtty-sts.aqtty) * nvl(df.amt,0)/(nvl(df.remainqtty,1) + nvl(df.rlsqtty,1)),
        nvl(df.amt,0)-nvl(df.rlsamt,0)),4),0) * (1+df.dealfeerate/100)) ODAMT into v_values
        from
        stschd sts, odmast od, (select * from v_getDealInfo where afacctno=fv_acctno) df
        where sts.orgorderid= od.orderid and od.dfacctno = df.acctno
        and od.exectype ='MS' and od.deltd <> 'Y'
        and sts.duetype ='RM' and sts.deltd <> 'Y'
        and od.afacctno=fv_acctno;
        v_values:=nvl(v_values,0);
    exception when others then
        v_values:=0;
    end;
    v_Result:=v_Result+v_values;

    --Lay khoan no cho lenh ban ETS
    for rec in
    (
        select a.afacctno, a.codeid,max(a.trade-nvl(vse.SECUREAMT,0)) trading,
            sum(c.qtty) orderqtty,
            max(nvl(vdf.overdftrading,0)) overdfqtty,
            max(nvl(vdf.dftrading,0))    dfqtty
        from semast a, odmast b, stschd c,
            v_getsellorderinfo vse,
            (
                select v.afacctno,v.codeid,
                sum(case when overamt>0 or (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T') then v.dftrading else 0 end) overdftrading,
                sum(case when overamt>0 or (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T') then 0 else v.dftrading end) dftrading  from
                (SELECT v.*, nvl(NML,0) DUEAMT,v.prinovd + v.oprinovd + nvl(NML,0) overamt
                FROM (select * from v_getDealInfo where afacctno=fv_acctno) v,
                (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
                        WHERE S.OVERDUEDATE <= v_strCURRDATE
                            AND S.NML > 0 AND S.REFTYPE IN ('P')
                            AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C')
                            and M.trfacctno=fv_acctno
                        GROUP BY S.ACCTNO, M.TRFACCTNO
                        ORDER BY S.ACCTNO) sts
                where v.lnacctno = sts.acctno (+)
                ) v WHERE v.status='A'
                group by v.afacctno,v.codeid
            ) vdf
        where a.acctno = b.seacctno and b.orderid = c.orgorderid
        and b.via ='W' and b.txdate =v_strCURRDATE
        and c.duetype='RM' and c.status='N' and c.deltd<>'Y'
        and a.acctno = vse.seacctno(+)
        and a.afacctno = vdf.afacctno(+)
        and a.codeid= vdf.codeid(+)
        and b.afacctno =fv_acctno
        group by a.afacctno,a.codeid
        order by a.codeid
    )
    loop
         v_overdfqtty:=least(rec.orderqtty,rec.overdfqtty);
         v_dfqtty:=least(rec.orderqtty-v_overdfqtty,rec.dfqtty,-v_overdfqtty-rec.trading);
         --1.Tra no cho cac deal den , qua han , trigger
         if v_overdfqtty>0 then
             for rec1 in
             (
                 select v.*
                 FROM (select * from v_getDealInfo where afacctno=rec.afacctno) v,
                        LNSCHD S, LNMAST M,securities_info sb
                 where v.lnacctno = m.acctno and m.acctno = s.acctno and s.REFTYPE IN ('P')
                 and v.codeid = sb.codeid
                 and (S.OVERDUEDATE <= v_strCURRDATE
                     or v.prinovd + v.oprinovd>0 or (sb.basicprice<=v.triggerprice or v.FLAGTRIGGER='T'))
                 and v.afacctno =rec.afacctno and v.codeid = rec.codeid
                 order by (case when (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T')
                                    then (v.triggerprice-v.basicprice)/greatest(v.basicprice ,1)
                                    else 0 end
                          ) desc,S.OVERDUEDATE
             )
             loop
                 v_values:=0;
                 if v_overdfqtty> rec1.dftrading then
                     v_dfrlsqtty:=rec1.dftrading;
                 else
                     v_dfrlsqtty:=v_overdfqtty;
                 end if;
                 --cspks_dfproc.pr_DealAutoPayment(p_txmsg,rec1.acctno,rec.autoid ,v_dfrlsqtty,1,v_paidamt ,p_err_code);
                 begin
                     select
                        greatest(round(least((v_dfrlsqtty) * nvl(df.amt,0)/(nvl(df.remainqtty,1) + nvl(df.rlsqtty,1)),
                        nvl(df.amt,0)-nvl(df.rlsamt,0)),4),0) * (1+df.dealfeerate/100) into v_values
                     from v_getDealInfo df
                     where df.acctno=rec1.acctno;
                     v_values:=nvl(v_values,0);
                 exception when others then
                     v_values:=0;
                 end;
                 v_Result:=v_Result+v_values;

                 v_overdfqtty:=v_overdfqtty-v_dfrlsqtty;
                 exit when v_overdfqtty<=0;
             end loop;
         end if;
         --2.Tra no cho cac deal trong han
         if v_dfqtty>0 then
             for rec1 in
             (
                 select v.*
                 FROM (select * from v_getDealInfo where afacctno=rec.afacctno) v,
				 LNSCHD S, LNMAST M,securities_info sb
                 where v.lnacctno = m.acctno and m.acctno = s.acctno and s.REFTYPE IN ('P')
                 and S.OVERDUEDATE > v_strCURRDATE AND sb.basicprice>v.triggerprice AND v.FLAGTRIGGER<>'T'
				 AND sb.codeid = v.codeid
                 and v.prinovd + v.oprinovd<=0
                 and v.afacctno =rec.afacctno and v.codeid = rec.codeid
                 order BY S.OVERDUEDATE
             )
             loop
                 v_values:=0;
                 if v_dfqtty> rec1.dftrading then
                     v_dfrlsqtty:=rec1.dftrading;
                 else
                     v_dfrlsqtty:=v_dfqtty;
                 end if;
                 begin
                     select
                        greatest(round(least((v_dfrlsqtty) * nvl(df.amt,0)/(nvl(df.remainqtty,1) + nvl(df.rlsqtty,1)),
                        nvl(df.amt,0)-nvl(df.rlsamt,0)),4),0) * (1+df.dealfeerate/100) into v_values
                     from v_getDealInfo df
                     where df.acctno=rec1.acctno;
                     v_values:=nvl(v_values,0);
                 exception when others then
                     v_values:=0;
                 end;
                 v_Result:=v_Result+v_values;

                 v_dfqtty:=v_dfqtty-v_dfrlsqtty;
                 exit when v_dfqtty<=0;
             end loop;
         end if;
    end loop;
    return v_Result;
EXCEPTION when others then
    return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
