SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI1021" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   COREBANK         IN       VARCHAR2,
   BANKNAME         IN       VARCHAR2
        )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
-- BAO CAO DANH SACH GIAO DICH LUU KY
-- Purpose: Briefly explain the functionality of the procedure
-- DANH SACH GIAO DICH LUU KY
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- NAMNT   11-APR-2012  MODIFIED
-- ---------   ------  -------------------------------------------

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (5);
    v_strIBRID     VARCHAR2 (4);
    vn_BRID        varchar2(50);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
    V_STRBANKNAME       VARCHAR(20);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS


 V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(pv_BRID,1,2) || '__' ;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;




   IF(COREBANK <> 'ALL')
   THEN
        V_STRCOREBANK  := COREBANK;
   ELSE
        V_STRCOREBANK  := '%%';
   END IF;

    IF(PV_CUSTODYCD <> 'ALL')
   THEN
        V_STRPV_CUSTODYCD  := PV_CUSTODYCD;
   ELSE
        V_STRPV_CUSTODYCD  := '%%';
   END IF;

    IF(PV_AFACCTNO <> 'ALL')
   THEN
        V_STRPV_AFACCTNO  := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%%';
   END IF;

    IF(BANKNAME <> 'ALL')
   THEN
        V_STRBANKNAME  := BANKNAME;
   ELSE
        V_STRBANKNAME := '%%';
   END IF;


 OPEN PV_REFCURSOR
  FOR

SELECT TL.BUSDATE ,cf.custodycd ,af.acctno ,cf.fullname ,tl.msgamt FROM  vw_tllog_all tl,afmast af ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
where tl.msgacct = af.acctno
and tl.deltd <> 'Y' and af.custid = cf.custid and tltxcd ='1138'
and af.corebank like V_STRCOREBANK
and af.bankname like V_STRBANKNAME
and tl.brid like V_STRBRID
and af.acctno like V_STRPV_AFACCTNO
and cf.custodycd like V_STRPV_CUSTODYCD
and tl.busdate BETWEEN TO_date (F_DATE,'DD/MM/YYYY') AND TO_date (T_DATE,'DD/MM/YYYY')
order by tl.busdate ,cf.custodycd
;


EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure

 
 
 
 
/
