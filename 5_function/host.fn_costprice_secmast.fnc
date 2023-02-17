SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_costprice_secmast
   (pv_seacctno in VARCHAR2,
    pv_date IN  DATE
    )
RETURN number
  IS
 v_return NUMBER ;
BEGIN

 SELECT  SUM (qtty*costprice)/sum(qtty) INTO v_return   FROM secmast WHERE  acctno||codeid  = pv_seacctno AND  txdate <= pv_date;

return v_return;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
/
