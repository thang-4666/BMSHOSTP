SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD1993" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
    TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2
)
IS


BEGIN
   /* V_P_date := TO_DATE(P_date,'dd/mm/rrrr');
    V_STRTLID:= TLID;
    V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


    V_STRCUSTODYCD := UPPER(CUSTODYCD);

    IF  (PV_AFACCTNO <> 'ALL')
    THEN
        V_STRAFACCTNO := PV_AFACCTNO;
    ELSE
        V_STRAFACCTNO := '%%';
    END IF;

    select to_date(varvalue,'dd/mm/rrrr') into V_CRRDATE  from sysvar where varname = 'CURRDATE';
    V_Set_day := getduedate(V_P_date, 'B', '000', 3);
*/
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
select 'DUNG' name, 'ngo huy dung' full_name from dual
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
