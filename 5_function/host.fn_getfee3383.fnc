SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getfee3383(PV_CURVALUE NUMBER ,pv_feecode varchar2, PV_RIGHTQTTY number,PV_CAMASTID VARCHAR2, pv_exprice number)
return number is
v_return number;
v_QTTY   NUMBER;
V_RIGHTOFFRATE    VARCHAR2(100);
V_EXPRICE         NUMBER(20);
V_AMT             NUMBER(20);
BEGIN
    SELECT RIGHTOFFRATE,EXPRICE INTO V_RIGHTOFFRATE,V_EXPRICE
    FROm CAMAST WHERE CAMASTID=PV_CAMASTID;
    V_EXPRICE := nvl(pv_exprice,0);
    /*V_QTTY:=FLOOR(PV_RIGHTQTTY*  TO_NUMBER(SUBSTR(V_RIGHTOFFRATE,instr(V_RIGHTOFFRATE,'/') + 1,length(V_RIGHTOFFRATE)))
                            /TO_NUMBER(substr(V_RIGHTOFFRATE,0,instr(V_RIGHTOFFRATE,'/') - 1)));*/
    V_QTTY := PV_RIGHTQTTY;
    V_AMT:=   V_QTTY*    V_EXPRICE;
    for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
    )
    loop
        if rec.forp = 'F' then
            v_return:= rec.feeamt;
        else
            v_return := round(V_AMT*rec.feerate/100);
            v_return := least(v_return, rec.maxval);
            v_return := greatest(v_return, rec.minval);
        end if;
        IF pv_feecode <> '777777' THEN
            return v_return;
        ELSE
            RETURN PV_CURVALUE;
        END IF;
    end loop;
    IF pv_feecode <> '777777' THEN
        return 0;
    ELSE
        RETURN PV_CURVALUE;
    END IF;
exception when others then
    return 99;
end;

 
 
 
 
/
