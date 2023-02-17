SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GL_EXP_TRAN" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                           PV_txdate       IN VARCHAR2,
                                           tltxcd       IN VARCHAR2,
                                           fromid        in number,
                                           toid        in number
                                           ) IS

  V_maxid       number;
  V_minid       number;
  V_TLTXCD VARCHAR2 (20) ;
  v_numrow       number;
  -- AUTHOER : NAMNT


BEGIN

if tltxcd = 'ALL' THEN
V_TLTXCD :='%';
ELSE
V_TLTXCD := tltxcd||'%';
END IF;

V_maxid:=0;
V_MINid:=0;

if fromid + toid = 0  then

SELECT MIN (REF) into V_minid
FROM (  select ref   from v_gl_exp_tran where txdate = PV_txdate ) ;

SELECT MAX (REF) into V_MAXid
FROM (  select ref   from v_gl_exp_tran where txdate = PV_txdate ) ;

 OPEN PV_REFCURSOR FOR
        select V_minid minid , V_maxid maxid  from dual ;

 ELSE

OPEN PV_REFCURSOR FOR
    select * from v_gl_exp_tran gl where gl.ref BETWEEN fromid and toid  and txdate = PV_txdate ;

end if ;


EXCEPTION
  WHEN others THEN
    return;
END;

 
 
 
 
/
