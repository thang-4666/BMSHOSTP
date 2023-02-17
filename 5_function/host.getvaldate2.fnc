SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETVALDATE2 (pv_trandate2 in varchar2) return varchar2
is
    l_valdate2 varchar2(20);
begin
    select to_char(min(sbdate), 'DD/MM/RRRR') INTO l_valdate2 from sbcldr where sbdate > to_date(pv_trandate2,'DD/MM/RRRR') and cldrtype = '000' and holiday <> 'Y';
    return l_valdate2;
exception when others then
    return pv_trandate2;
end;

 
 
 
 
 
 
 
 
 
 
 
/
