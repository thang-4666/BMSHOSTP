SET DEFINE OFF;
CREATE OR REPLACE function fn_getusedselimitbygroup (p_grpid IN VARCHAR2)
RETURN NUMBER
  IS
l_amt number;
BEGIN
    select nvl(sum(fn_getUsedSeLimit(af.afacctno, se.codeid)),0) amt
        into l_amt
    from afselimitgrp af ,selimitgrp se
    where af.refautoid = se.autoid
         and af.refautoid = p_grpid;
    return l_amt;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
/
