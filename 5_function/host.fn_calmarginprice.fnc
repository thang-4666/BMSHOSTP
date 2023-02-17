SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_calmarginprice(p_symbol varchar2,p_calprice number, p_nextdate varchar2 default 'N') return NUMBER
is
    v_currdate date;
    v_count number;
    v_calprice number;
    l_symbol varchar2(100);
    l_tradeplace    varchar2(10);
begin
    if p_nextdate='Y' then
        SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') CURRDATE INTO v_currdate
        FROM SYSVAR
        WHERE GRNAME = 'SYSTEM' AND VARNAME ='NEXTDATE';
    else
        v_currdate:= getcurrdate;
    end if;
    v_calprice:= p_calprice;

    l_symbol:= replace(p_symbol,'_WFT','');--Ma WFT duoc tinh theo ma goc

    select max(tradeplace) into l_tradeplace from sbsecurities where symbol = l_symbol;
    if p_nextdate='O' and l_tradeplace <> '001' then
        select count(1) into v_count from rightoffevent
        where symbol =l_symbol and begindate<=v_currdate and v_currdate<= getduedate(enddate,'B',l_tradeplace,1);
        if v_count>0 THEN
            for rec in (select * from rightoffevent where symbol =l_symbol and begindate<=v_currdate
                and v_currdate<=getduedate(enddate,'B',l_tradeplace,1))
            loop
                if rec.autocalc='Y' then
                    v_calprice:=(p_calprice + (rec.i1*rec.pr1) + (rec.i2*rec.pr2) + (rec.i3*rec.pr3) - rec.tthcp-rec.divcp-rec.ttht-rec.divt)
                                /(1+rec.i1+rec.i2+rec.i3);
                    v_calprice:=LEAST(v_calprice,p_calprice);
                    return v_calprice;
                else
                    /*v_calprice:=(rec.basicprice + (rec.i1*rec.pr1) + (rec.i2*rec.pr2) + (rec.i3*rec.pr3) - rec.tthcp-rec.divcp-rec.ttht-rec.divt)
                                /(1+rec.i1+rec.i2+rec.i3);*/
                    v_calprice:=rec.basicprice;
                    v_calprice:=LEAST(v_calprice,p_calprice);
                    return v_calprice;
                end if;
            end loop;
        end if;
        -- Truongf hop gia dong cua <10 se bi dieu chinh len
        v_calprice:=LEAST(v_calprice,p_calprice);
        return v_calprice;
    else
		select count(1) into v_count from rightoffevent where symbol =l_symbol and begindate<=v_currdate
                and v_currdate<=  (case  when  l_tradeplace <> '001'  and  p_nextdate ='Y' THEN  getduedate(enddate,'B',l_tradeplace,1) ELSE ENDDATE END );
        if v_count>0 THEN
            for rec in (select * from rightoffevent where symbol =l_symbol and begindate<=v_currdate
                and v_currdate<=  case  when  l_tradeplace <> '001'  and  p_nextdate ='Y' THEN  getduedate(enddate,'B',l_tradeplace,1) ELSE ENDDATE END )
            loop
                if rec.autocalc='Y' then
                    v_calprice:=(p_calprice + (rec.i1*rec.pr1) + (rec.i2*rec.pr2) + (rec.i3*rec.pr3) - rec.tthcp-rec.divcp-rec.ttht-rec.divt)
                                /(1+rec.i1+rec.i2+rec.i3);
                    v_calprice:=LEAST(v_calprice,p_calprice);
                    return v_calprice;
                else
                    /*v_calprice:=(rec.basicprice + (rec.i1*rec.pr1) + (rec.i2*rec.pr2) + (rec.i3*rec.pr3) - rec.tthcp-rec.divcp-rec.ttht-rec.divt)
                                /(1+rec.i1+rec.i2+rec.i3);*/
                    v_calprice:=rec.basicprice;
                    v_calprice:=LEAST(v_calprice,p_calprice);
                    return v_calprice;
                end if;
            end loop;
        end if;
        -- Truongf hop gia dong cua <10 se bi dieu chinh len
        v_calprice:=LEAST(v_calprice,p_calprice);
        return v_calprice;
    end if;

EXCEPTION when others then
    return v_calprice;
end;
 
 
 
 
/
