SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE00861" (
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
SELECT cf.fullname ho_ten, grp.fullname ten_nhom, com.commdate,
        grpcommision tong_thuong_vuotdm,
        CASE WHEN grp.custid = com.custid THEN 'Truong nhom chinh' ELSE 'Truong nhom phu' END chuc_vu,
        round(com.commision/decode(grpcommision,0,0.000001,grpcommision),2) * 100 TL,
        com.commision
FROM recommision com, cfmast cf, regrp grp
WHERE com.custid = cf.custid
AND com.retype = 'I'
AND grp.autoid = com.refrecflnkid
AND com.commdate <= VT_DATE AND com.commdate >= VF_DATE
AND SP_FORMAT_REGRP_MAPCODE(com.refrecflnkid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
AND (V_LEADERCUSTID LIKE V_STRBRID OR instr(V_STRBRID,V_LEADERCUSTID)<> 0)
AND grpcommision > 0
ORDER BY  com.commdate, SP_FORMAT_REGRP_MAPCODE(com.refrecflnkid),  chuc_vu
/*SELECT nvl(lead.fullname,' ') fullname, nvl(lead.rate,0) rate, nvl(com.commision,0) commision FROM
(SELECT lead.*, cf.fullname fullname FROM regrpleaders lead, cfmast cf
WHERE nvl(lead.closedate,'01/01/2999') >= VF_DATE AND lead.activedate <= VT_DATE
AND  SP_FORMAT_REGRP_MAPCODE(lead.grpid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
AND cf.custid = lead.custid
) lead,
(SELECT com.refrecflnkid, com.custid, sum(nvl(com.commision,0)) commision FROM recommision com WHERE com.retype = 'I'
AND  com.commdate <= VT_DATE AND com.commdate >= VF_DATE
AND SP_FORMAT_REGRP_MAPCODE(com.refrecflnkid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
GROUP BY com.refrecflnkid, com.custid
)com
WHERE lead.custid = com.custid (+) AND lead.grpid = com.refrecflnkid(+)*/
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
