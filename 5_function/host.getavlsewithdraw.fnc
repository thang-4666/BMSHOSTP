SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getavlsewithdraw (p_seacctno in varchar2)
  RETURN number IS

l_AVLSEWITHDRAW NUMBER(20,2);
    l_sewithdrawcheck_arr txpks_check.sewithdrawcheck_arrtype;
BEGIN
     l_sewithdrawcheck_arr := txpks_check.fn_sewithdrawcheck(p_seacctno,'SEWITHDRAW','ACCTNO');
     l_AVLSEWITHDRAW := l_sewithdrawcheck_arr(0).AVLSEWITHDRAW;
     RETURN l_AVLSEWITHDRAW;
exception when others then
    
    return 0;
END; 
 
 
 
 
 
 
 
 
 
 
 
/
