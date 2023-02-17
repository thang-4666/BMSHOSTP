SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETMR0002" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, TLID IN VARCHAR2)
  IS

  v_TLID VARCHAR2(20);

BEGIN
v_TLID:= TLID;

OPEN PV_REFCURSOR FOR

select * from vw_mr0002 mr, afmast af where mr.acctno = af.acctno
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID );

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
