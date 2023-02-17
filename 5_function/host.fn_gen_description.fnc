SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_DESCRIPTION(pv_CATYPE In VARCHAR2, pv_OPTSYMBOL IN VARCHAR2,pv_REPORTDATE IN VARCHAR2,
                                              pv_DEVIDENTRATE in VARCHAR2,pv_DEVIDENTVALUE IN VARCHAR2,pv_TYPERATE IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(1000);

BEGIN
  -- chia co tuc bang tien
    if(pv_CATYPE='010') THEN
             if(pv_TYPERATE='R') THEN -- chia theo ti le
             v_result:= 'Chia cổ tức bằng tiền, '||pv_OPTSYMBOL||', ' || 'ngày chốt ' || pv_REPORTDATE || ', tỷ lệ ' ||pv_DEVIDENTRATE || '%';
             ELSE
             v_result:= 'Chia cổ tức bằng tiền, '||pv_OPTSYMBOL||', ' || 'ngày chốt ' || pv_REPORTDATE || ', giá trị ' ||pv_DEVIDENTVALUE;
             END IF;
    END if;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 'A';
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
