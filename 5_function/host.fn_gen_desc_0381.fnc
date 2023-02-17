SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_desc_0381 (p_desccription varchar2,p_oldcust varchar2, p_newcust varchar2) return string
is
v_desc varchar2(500);
V_oldcust varchar2(500);
V_newcust varchar2(100);
V_FULLNAME varchar2(500);
V_TYPENAME varchar2(500);
begin

       v_desc:=nvl(p_desccription,'') ;
       V_oldcust:=nvl(p_oldcust,'');
       V_newcust:=nvl(p_newcust,'');

       SELECT FULLNAME INTO V_FULLNAME FROM CFMAST WHERE CUSTID=SUBSTR(V_newcust,1,10);
       SELECT TYPENAME INTO V_TYPENAME FROM RETYPE WHERE ACTYPE=SUBSTR(V_newcust,11);


       v_desc:= 'Chuyển môi giới từ (' || V_oldcust ||  ') sang (' || V_FULLNAME||'/'||V_TYPENAME || ')';

 return v_desc;
exception when others then
       return 'Chuyen moi gioi';
end;

 
 
 
 
/
