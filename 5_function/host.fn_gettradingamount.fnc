SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettradingamount(p_afacctno varchar2, p_odtype varchar2)
return NUMBER
is
    v_tradingAmount number;
    v_brkfeetype char(2);
    v_custid varchar2(10);
    v_count number;
    v_DATE date;
begin
    v_tradingAmount:=0;
    v_DATE:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'dd/mm/rrrr');
    select brkfeetype, custid into v_brkfeetype, v_custid from afmast where acctno = p_afacctno;
    if v_brkfeetype='CF' then --Tinh phi theo so luu ky
        select sum(od.execamt) totalexec into v_tradingAmount
            from odmast od,odtype typ, sbsecurities sb
            where od.deltd <> 'Y' and od.execqtty > 0
                  and od.exectype in ('NB','BC','SS','NS','MS')
                  and od.codeid= sb.codeid
                  AND (typ.via = od.via OR typ.via = 'A') --VIA
                  AND typ.clearcd = od.clearcd       --CLEARCD
                  AND (typ.exectype = od.exectype OR typ.exectype = 'AA') --EXECTYPE
                  AND (typ.timetype = od.timetype OR typ.timetype = 'A') --TIMETYPE
                  AND (typ.pricetype = od.pricetype OR typ.pricetype = 'AA') --PRICETYPE
                  AND (typ.matchtype = od.matchtype OR typ.matchtype = 'A') --MATCHTYPE
                  AND (typ.tradeplace = sb.tradeplace OR typ.tradeplace = '000')
                  AND (instr(case when sb.sectype in ('001','002') then sb.sectype || ',' || '111,333'
                                   when sb.sectype in ('003','006') then sb.sectype || ',' || '222,333,444'
                                   when sb.sectype in ('008') then sb.sectype || ',' || '111,444'
                                   else sb.sectype end , typ.sectype)>0 OR typ.sectype = '000')
                  AND (typ.nork = od.nork OR typ.nork = 'A') --NORK
                  AND (CASE WHEN typ.CODEID IS NULL THEN od.codeid ELSE typ.CODEID END)=od.codeid
                  and typ.status = 'Y'
                  and od.txdate = v_DATE
                  and od.afacctno in (select acctno from afmast where custid = v_custid and brkfeetype='CF')
                  and typ.actype =p_odtype;
        return nvl(v_tradingAmount,0);

    else --Tinh phi theo tieu khoan va nhom tieu khoan
        select count(autoid) into v_count from afbrkfeegrp where afacctno = p_afacctno;
        if v_count>0 then --Tinh phi theo nhom
            select sum(od.execamt) totalexec into v_tradingAmount
            from odmast od,odtype typ, sbsecurities sb, afbrkfeegrp grp
            where od.deltd <> 'Y' and od.execqtty > 0
                  and od.exectype in ('NB','BC','SS','NS','MS')
                  and od.codeid= sb.codeid
                  AND (typ.via = od.via OR typ.via = 'A') --VIA
                  AND typ.clearcd = od.clearcd       --CLEARCD
                  AND (typ.exectype = od.exectype OR typ.exectype = 'AA') --EXECTYPE
                  AND (typ.timetype = od.timetype OR typ.timetype = 'A') --TIMETYPE
                  AND (typ.pricetype = od.pricetype OR typ.pricetype = 'AA') --PRICETYPE
                  AND (typ.matchtype = od.matchtype OR typ.matchtype = 'A') --MATCHTYPE
                  AND (typ.tradeplace = sb.tradeplace OR typ.tradeplace = '000')
                  AND (instr(case when sb.sectype in ('001','002') then sb.sectype || ',' || '111,333'
                                   when sb.sectype in ('003','006') then sb.sectype || ',' || '222,333,444'
                                   when sb.sectype in ('008') then sb.sectype || ',' || '111,444'
                                   else sb.sectype end , typ.sectype)>0 OR typ.sectype = '000')
                  AND (typ.nork = od.nork OR typ.nork = 'A') --NORK
                  AND (CASE WHEN typ.CODEID IS NULL THEN od.codeid ELSE typ.CODEID END)=od.codeid
                  and typ.status = 'Y'
                  and od.txdate = v_DATE
                  and od.afacctno= grp.afacctno
                  and grp.refautoid in (select max(refautoid) from afbrkfeegrp where afacctno = p_afacctno)
                  and typ.actype =p_odtype;
            return nvl(v_tradingAmount,0);
        else --Tinh phi theo tieu khoan
            select sum(od.execamt) totalexec into v_tradingAmount
            from odmast od,odtype typ, sbsecurities sb
            where od.deltd <> 'Y' and od.execqtty > 0
                  and od.exectype in ('NB','BC','SS','NS','MS')
                  and od.codeid= sb.codeid
                  AND (typ.via = od.via OR typ.via = 'A') --VIA
                  AND typ.clearcd = od.clearcd       --CLEARCD
                  AND (typ.exectype = od.exectype OR typ.exectype = 'AA') --EXECTYPE
                  AND (typ.timetype = od.timetype OR typ.timetype = 'A') --TIMETYPE
                  AND (typ.pricetype = od.pricetype OR typ.pricetype = 'AA') --PRICETYPE
                  AND (typ.matchtype = od.matchtype OR typ.matchtype = 'A') --MATCHTYPE
                  AND (typ.tradeplace = sb.tradeplace OR typ.tradeplace = '000')
                  AND (instr(case when sb.sectype in ('001','002') then sb.sectype || ',' || '111,333'
                                   when sb.sectype in ('003','006') then sb.sectype || ',' || '222,333,444'
                                   when sb.sectype in ('008') then sb.sectype || ',' || '111,444'
                                   else sb.sectype end , typ.sectype)>0 OR typ.sectype = '000')
                  AND (typ.nork = od.nork OR typ.nork = 'A') --NORK
                  AND (CASE WHEN typ.CODEID IS NULL THEN od.codeid ELSE typ.CODEID END)=od.codeid
                  and typ.status = 'Y'
                  and od.txdate = v_DATE
                  and od.afacctno= p_afacctno
                  and typ.actype =p_odtype;
            return nvl(v_tradingAmount,0);
        end if;
    end if;
    return 0;
EXCEPTION when others then
    return 0;
end fn_getTradingAmount;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
