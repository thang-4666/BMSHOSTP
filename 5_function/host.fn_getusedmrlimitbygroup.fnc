SET DEFINE OFF;
CREATE OR REPLACE function fn_getusedmrlimitbygroup (p_grpid IN VARCHAR2)
RETURN NUMBER
  IS
l_amt number;
BEGIN
    select nvl(sum(fn_getUsedMrLimit(afacctno)),0) amt
        into l_amt
    from afmrlimitgrp where refautoid = p_grpid;
    return l_amt;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
 
 
/
