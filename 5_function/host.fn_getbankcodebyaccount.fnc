SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getbankcodebyaccount(pv_bankaccount varchar2) return VARCHAR2
is
l_bankcode varchar2(10);
begin
    if substr(pv_bankaccount,1,1) = '0' then --Tai khoan hoi so
        l_bankcode:='XXXXXXXX';
    else
        select nvl(bankcode,'XXXXXXXX') into l_bankcode from crbbankmap where bankid = substr(pv_bankaccount,1,3);
    end if;
    return l_bankcode;
exception when others then
    return 'XXXXXXXX';
end;

 
 
 
 
 
 
 
 
 
 
 
/
