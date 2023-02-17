SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getmaxqtty_release( pv_ACCTNO IN VARCHAR2)
    RETURN NUMBER IS
    v_Result  NUMBER;
    l_groupid  VARCHAR2(100);
    l_ddf number;
    l_rttdf NUMBER;
    l_oldqtty number ;
    l_afacctno VARCHAR2(10);
    l_dfqtty number;
    l_irate number;
    l_codeid varchar2(10);
    l_tadf number ;
    l_dfrefprice number ;
    l_dfrate  number ;
BEGIN
   select groupid ,afacctno,dfqtty,codeid,dfrate
   into l_groupid,l_afacctno,l_dfqtty, l_codeid,l_dfrate
   from dfmast where acctno =pv_ACCTNO;
     select irate into l_irate from  dfgroup where groupid= l_groupid;

   select ddf,tadf into l_ddf,l_tadf from  v_getgrpdealformular where groupid= l_groupid;
   select dfrefprice into l_dfrefprice from securities_info where codeid =l_codeid;

v_Result:= LEAST(  GREATEST ((l_tadf-l_ddf*l_irate/100)/(l_dfrefprice*l_dfrate/100),0),l_dfqtty);
-- (l_tadf - x)/l_ddf = l_irate/100




    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
