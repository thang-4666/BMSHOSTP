SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getnonworkingday(p_wokingday number) return number
is
v_nonwworkingday number;
begin
    select sbdate-currdate into v_nonwworkingday from sbcurrdate where numday = p_wokingday and sbtype ='B';
    return v_nonwworkingday;
exception when others then
    return 3;
end;

 
 
 
 
 
 
 
 
 
 
 
/
