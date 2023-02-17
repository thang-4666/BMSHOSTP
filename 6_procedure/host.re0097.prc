SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0097" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2
 )
IS
--bao cao PHAN BO THUONG CONG TAC VIEN
--created by Chaunh at 06/09/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_CUSTID varchar2(10);
    V_RENAME varchar2(50);
    V_NHOM varchar2(50);
    V_MININCOME NUMBER;
    V_DINHMUC_CS NUMBER;
    V_DINHMUC_DC NUMBER;
    V_COMMISION NUMBER;
    V_TLHT NUMBER;

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   -----------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');
   V_CUSTID := CUSTID;
   IF (CUSTID <> 'ALL')
   THEN
    BEGIN
        V_CUSTID := CUSTID;
        SELECT nvl(cf.fullname,' ') INTO V_RENAME FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE cf.custid like V_CUSTID;
        SELECT max(nvl(rgp.fullname,' ')) INTO V_NHOM FROM regrp rgp, regrplnk lnk, retype
            WHERE lnk.custid LIKE V_CUSTID AND lnk.refrecflnkid = rgp.autoid
            AND greatest(lnk.frdate,rgp.effdate) <= VT_DATE AND least(nvl(lnk.clstxdate,lnk.todate),rgp.expdate) >= VF_DATE
            AND retype.actype = substr(lnk.reacctno,11,4) AND retype.rerole = 'RM'
            ;

    END ;
   ELSE
    V_CUSTID := '%';
    V_RENAME := 'ALL';
    V_NHOM := 'ALL';
   END IF;

   --tinh doanh so dinh muc truc tiep
   select nvl(max(re.mindrevamt),0), nvl(max(re.mindrevamt),0)*(1 - max(re.revrate)/100) into V_DINHMUC_DC, V_DINHMUC_CS
   from recommision re, recflnk
   where re.commdate =  (select max(re.commdate) from recommision re, recflnk
                            where re.custid = V_CUSTID and re.retype = 'D'
                            AND re.custid = recflnk.custid
                            AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
                            and re.commdate <= VT_DATE and re.commdate >= VF_DATE )
   and re.custid = V_CUSTID  and re.retype = 'D'
   AND re.custid = recflnk.custid
   AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
   and re.commdate <= VT_DATE and re.commdate >= VF_DATE;

   --tinh tong luong dinh muc
   select nvl(sum(s),0) into V_MININCOME
   from (
            select  nvl(max(re.minincome),0) s,  re.retype-- into V_tong_luong_dm
            from recommision re, recflnk
            where re.commdate = (select max(re.commdate) from recommision re, recflnk
                                where  re.custid = V_CUSTID
                                AND re.custid = recflnk.custid
                                AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
                                AND re.commdate >= VF_DATE AND re.commdate <= VT_DATE
                                )
            and re.custid = V_CUSTID
            AND re.custid = recflnk.custid
            AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
        group by re.retype
        )
   ;
   --tinh ty le ht
   select nvl(CASE WHEN  mindrevamt = 0 THEN 0
            ELSE round(directacr*commdays/bmdays/mindrevamt*100,2) END,0) into V_TLHT
   from (
            select  re.mindrevamt, sum(re.directacr) directacr, re.commdays, re.bmdays
            from recommision re, recflnk
            where re.commdate = (select max(re.commdate) from recommision re, recflnk
                                where  re.custid = V_CUSTID
                                AND re.custid = recflnk.custid
                                AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
                                AND re.commdate >= VF_DATE AND re.commdate <= VT_DATE
                                )
            and re.custid = V_CUSTID AND re.retype = 'D'
            AND re.custid = recflnk.custid
            AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
        group by re.mindrevamt, re.commdays, re.bmdays
        )
   ;
   --tinh luong
   SELECT  nvl(sum(sa.commision),0)
    INTO  V_COMMISION
    FROM resalary sa, recflnk
    where sa.custid = V_CUSTID AND sa.custid = recflnk.custid
    AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
    AND sa.commdate >= VF_DATE AND sa.commdate <= VT_DATE;
      ------------------------------

OPEN PV_REFCURSOR FOR
SELECT (typename || '_' || retype.actype) typename,
        def.effdays,
        a.cdcontent rerole, ratecomm, directacr gt_gd,
       V_TLHT tl_ht,
       com.commision commsion,
       V_RENAME ten, V_NHOM phong, V_MININCOME luongthoathuan ,  V_DINHMUC_CS dm_cs,   V_DINHMUC_DC dm_dc,    V_COMMISION thuong
FROM retype, recommision com, recflnk cf, recfdef def, ICCFTYPEDEF icc, allcode a, recflnk,
(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)CF1,reaflnk kh, CFMAST
where com.reactype = retype.actype
AND KH.refrecflnkid=cf.Autoid
AND CF1.CUSTID=KH.AFACCTNO
AND cf.autoid = def.refrecflnkid
AND com.acctno = cf.custid||def.reactype
AND retype.rerole = 'RM'
AND icc.modcode = 'RE' AND icc.eventcode = 'CALFEECOMM' AND icc.actype = retype.actype
AND a.CDTYPE = 'SA' AND a.CDNAME = 'RULETYPE' AND a.CDVAL NOT IN ('S') AND a.cdval = icc.ruletype
AND com.custid = recflnk.custid
AND COM.CUSTID=CFMAST.CUSTID
AND com.custid LIKE V_CUSTID AND com.commdate <= VT_DATE AND com.commdate >= VF_DATE
AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
ORDER BY retype.actype
;


EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
