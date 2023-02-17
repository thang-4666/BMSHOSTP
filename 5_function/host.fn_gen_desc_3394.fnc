SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_desc_3394 (p_description varchar2,p_qtty varchar2) return string
is
v_desc varchar2(500);
v_qtty varchar2(500);

begin
       v_desc:=nvl(p_description,'') ;
       v_qtty:=nvl(p_qtty,'') ;
       if length(v_qtty)>0 then
          v_desc:= replace(v_desc,'<$21QTTY>',v_qtty);
       end if;
       return v_desc;
exception when others then
       return 'Đăng ký mua CP phát hành thêm';
end;

 
 
 
 
 
 
 
 
 
 
 
/
