SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_DESC_CAMAST_028 (p_codeid varchar2,p_Reportdate varchar2, p_typeRate varchar2,p_rate varchar2, p_value varchar2,p_EXPRICE varchar2) return string
is
v_desc varchar2(500);
v_symbol varchar2(20);
begin
       v_desc:='Chi trả lợi tức chứng quyền, <$CODEID>, ngày chốt <$REPORTDATE>, <$DES>, giá thanh toán <$EXPRICE>' ;

       if length(p_codeid)>0 then
    begin
    select symbol into v_symbol from sbsecurities where codeid=p_codeid;
    EXCEPTION
    WHEN OTHERS
       THEN
       v_symbol := p_codeid;

    END;
          v_desc:= replace(v_desc,'<$CODEID>',v_symbol);
       end if;
       v_desc:= replace(v_desc,'<$REPORTDATE>',p_Reportdate);
       if (p_typeRate ='R') then
         v_desc:= replace(v_desc,'<$DES>','tỷ lệ '||trim(to_char(to_number(p_rate),'9,999,999,999,999,999,990.999999'))||'%');
       else
          v_desc:= replace(v_desc,'<$DES>','giá trị '||trim(to_char(to_number(p_value),'9,999,999,999,999,999,990.999999')));
       end if;
       v_desc:= replace(v_desc,'<$EXPRICE>',trim(to_char(to_number(p_EXPRICE),'9,999,999,999,999,999,999')));
       return v_desc;
exception when others then
       return 'Chi trả lợi tức chứng quyền';
end;

 
/
