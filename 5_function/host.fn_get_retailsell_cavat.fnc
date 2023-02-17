SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_retailsell_cavat(p_qtty number, p_seacctno varchar2) return number
is
v_cavat number;
v_qtty number;
v_caqtty number;
begin
    v_qtty:=p_qtty;
    v_caqtty:=0;
    v_cavat:=0;
    for rec in(
        select * from sepitlog where deltd <> 'Y' and qtty-mapqtty>0
        and acctno =p_seacctno
        order by txdate, autoid
    )
    loop
        if v_qtty>rec.qtty-rec.mapqtty then
            v_caqtty:=v_caqtty+rec.qtty-rec.mapqtty;
            v_cavat:=v_cavat + (rec.qtty-rec.mapqtty) * rec.pitrate;
            v_qtty:=v_qtty-rec.qtty+rec.mapqtty;
        else
            v_caqtty:=v_caqtty+v_qtty;
            v_cavat:=v_cavat+v_qtty * rec.pitrate;
            v_qtty:=0;
        end if;
        exit when v_qtty<=0;
    end loop;
    return v_cavat;
end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
