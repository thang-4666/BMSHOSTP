SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE00860" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
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
--remake by Chaunh at 31/08/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    V_LEADERCUSTID varchar2(15);
BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := BRID;
        end if;
    end if;

   IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;

   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

   SELECT recflnk.brid INTO V_LEADERCUSTID FROM regrp, recflnk WHERE regrp.autoid = V_GROUPID AND regrp.custid = recflnk.custid;

OPEN PV_REFCURSOR FOR
SELECT /*cf.fullname ho_ten, com.minincome,*/
        MAX(grp.fullname) ten_nhom, com.commdate,  com.minirevamt, com.indirectacr,
       case WHEN com.minirevamtreal = 0 THEN 0
            ELSE round(com.indirectacr/com.minirevamtreal*100,2) END  tl_ht,
       com.disdirectacr, NVL(GRPCOMMISION,0) commision,
       com.revrate tl_dieuchinh,
      com.minirevamtreal*(1 - com.revrate/100) dm_coban,
      minirevamtreal dm_dieuchinh

FROM recommision com, cfmast cf, regrp grp, recflnk
WHERE com.custid = cf.custid
AND com.retype = 'I'
AND grp.autoid = com.refrecflnkid
AND com.commdate <= VT_DATE AND com.commdate >= VF_DATE
AND SP_FORMAT_REGRP_MAPCODE(com.refrecflnkid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
AND com.custid = recflnk.custid
AND (V_LEADERCUSTID LIKE V_STRBRID OR instr(V_STRBRID,V_LEADERCUSTID)<> 0)
GROUP BY com.commdate,  com.minirevamt, com.indirectacr,
       case WHEN com.minirevamtreal = 0 THEN 0
            ELSE round(com.indirectacr/com.minirevamtreal*100) END  ,
       com.disdirectacr,  NVL(GRPCOMMISION,0),
       com.revrate ,
       --com.minirevamt*(1 - com.revrate/100),
       minirevamtreal
ORDER BY com.commdate
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
