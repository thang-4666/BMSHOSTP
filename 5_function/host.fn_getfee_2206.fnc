SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getfee_2206(PV_CURVALUE NUMBER,PV_CALTYPE VARCHAR2,pv_feecode varchar2, PV_QTTY number,PV_AMT number, pv_CODEID VARCHAR2,pv_OPNFBORS VARCHAR2)
return number is
    v_return    number(20);
    v_NAV       NUMBER(20);

    V_FORP      varchar2(10);
    v_feeamt    number(10);
    v_feerate   number(10,4);
    v_minval    number(20);
    v_maxval    number(20);
    l_feecode   varchar2(20);

BEGIN

    if PV_CALTYPE = '02' then
        return PV_CURVALUE;
    end if;

    ---l_feecode := SUBSTR(pv_feecode,);
    --l_feecode := SUBSTR(pv_feecode,0,INSTR(pv_feecode,'-')-1);

    select FORP, feeamt, feerate, minval, maxval into V_FORP, v_feeamt, v_feerate, v_minval, v_maxval
    from feemaster where feecd = pv_feecode;

    select nvl(min(NAV),0) into v_NAV from securities_nav
    where codeid = pv_CODEID and getcurrdate between fromdate and todate;

    if V_FORP = 'F' then
        return v_feeamt;
    elsif V_FORP = 'P' then
        if pv_OPNFBORS in ('OPFIPO','OPFSPO','OPFBUY') then
            return PV_AMT*(v_feerate/100);
        elsif pv_OPNFBORS in ('OPFSEL') then
            return PV_QTTY*v_NAV*(v_feerate/100);
        else
            return 0;
        end if;
    else
        if pv_OPNFBORS in ('OPFIPO','OPFSPO','OPFBUY') then
            select nvl(min(rate),0) into v_feerate from feemasterschm
                where refautoid = pv_feecode and PV_AMT >= framt and PV_AMT < toamt;
            return PV_AMT*(v_feerate/100);
        else
            return 0;
        end if;
    end if;

    /*if pv_OPNFBORS in ('OPFSWP','OPFSEL') then
        SELECT MIN(nvl(ISS.NAV,0)) into v_NAV
        FROM SBSECURITIES SB, ISSUERS ISS WHERE SB.CODEID = pv_CODEID AND SB.ISSUERID = ISS.ISSUERID;
        if V_FORP = 'T' then
            select min(rate) into v_feerate from feemasterschm
                where refautoid = pv_feecode and PV_QTTY >= framt and PV_QTTY < toamt;
        end if;
        v_return := PV_QTTY*v_NAV*(v_feerate/100);
        return v_return;
    end if;
    if pv_OPNFBORS = 'OPFSPO' then
        if V_FORP = 'T' then
            select min(rate) into v_feerate from feemasterschm
                where refautoid = pv_feecode and PV_AMT >= framt and PV_AMT < toamt;
        end if;
        v_return := PV_AMT*(20/100)*(v_feerate/100);
        return v_return;
    end if;

    if pv_OPNFBORS in ('OPFIPO','OPFBUY','OPFSWP','OPFTRI','OPFTRO') then
        if V_FORP = 'T' then
            select min(rate) into v_feerate from feemasterschm
                where refautoid = pv_feecode and PV_AMT >= framt and PV_AMT < toamt;
        end if;
        v_return := PV_AMT*(v_feerate/100);
        return v_return;
    end if;*/
exception when others then
    return 0;
end;
 
 
 
 
/
