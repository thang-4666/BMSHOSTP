SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_correct_price
   (pv_CodeID IN  char,
    pv_PRICE in number,
    pv_PRICETYPE in char -- tran hay san
    )
RETURN number
  IS
  v_return number;
  v_PRICE  number;
  v_strError NVARCHAR2(20);
BEGIN
   v_PRICE :=0;
   v_PRICE:=pv_PRICE;

case
when v_PRICE <50000 then
         -- Buoc gia lam tron den don vi 100-------------
         If pv_PRICETYPE='C' then
           v_return:=Floor(v_PRICE/100)*100;
         else
           v_return:=Ceil(v_PRICE/100)*100;
         end if;

when v_PRICE <100000 And v_PRICE >= 50000 then

        If pv_PRICETYPE='C' then
           v_return:=Floor(v_PRICE/500)*500;
         else
           v_return:=Ceil(v_PRICE/500)*500;
         end if;

when v_PRICE >=100000  then
     -- Buoc gia lam tron den don vi 1000-------------
     If pv_PRICETYPE='C' then
           v_return:=Floor(v_PRICE/1000)*1000;
         else
           v_return:=Ceil(v_PRICE/1000)*1000;
         end if;
null;

end case;

return v_return;

EXCEPTION
    WHEN others THEN
      v_strError :=SQLERRM ;
            INSERT INTO log_err (id,date_log, POSITION, text)
            VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' quyet.kieu : fn_correct_price' || pv_CodeID  ,v_strError);
           commit;
        return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
