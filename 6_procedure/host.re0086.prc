SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0086" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2
 )
IS
--bao cao gia tri giao dich truc tiep - nhom
--created by Chaunh at 18/01/2012
--14/03/2012 repair
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    V_LEADERCUSTID varchar2(15);
BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;

   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

   SELECT nvl(custid,' ') INTO V_LEADERCUSTID FROM regrp WHERE regrp.autoid = V_GROUPID;

OPEN PV_REFCURSOR FOR
SELECT cf.fullname ho_ten, grp.fullname ten_nhom, com.commdate, com.minincome, com.minirevamt, com.indirectacr,
       case WHEN com.minirevamtreal = 0 THEN 0
            ELSE round(com.indirectacr/com.minirevamtreal*100) END  tl_ht,
       com.disdirectacr, com.commision
FROM recommision com, (SELECT * FROM CFMAST/* WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/) cf, regrp grp
WHERE com.custid = cf.custid
AND com.retype = 'I'
AND grp.autoid = com.refrecflnkid
AND com.commdate <= VT_DATE AND com.commdate >= VF_DATE
AND SP_FORMAT_REGRP_MAPCODE(com.refrecflnkid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
AND (substr(V_LEADERCUSTID,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(V_LEADERCUSTID,1,4))<> 0)
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
