SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0094" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2
 )
IS
--bao cao danh sach moi gioi
--created by Chaunh at 16/01/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);

    V_GROUPCUSTID varchar2(20);

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   IF GROUPID <> 'ALL' THEN
      BEGIN
        V_GROUPID := GROUPID;
        SELECT recflnk.brid INTO V_GROUPCUSTID FROM regrp g, recflnk WHERE  g.autoid LIKE  V_GROUPID  AND g.custid = recflnk.custid;
      END ;
   ELSE
      BEGIN
        V_GROUPID := '%';
        V_GROUPCUSTID := ' ';
      END;
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');



OPEN PV_REFCURSOR FOR
SELECT ten_moi_gioi, ma_moi_gioi, vi_tri, nhom, ma_nhom, ngay_vao_nhom, ngay_ra_nhom, cap, MOI_GIOI_CHA, MAPLEVEL FROM
    (
    SELECT refrecflnkid ma_nhom, regrplnk.custid , reacctno ma_moi_gioi, frdate ngay_vao_nhom, nvl(clstxdate,todate) ngay_ra_nhom, to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent) vi_tri
        FROM regrplnk, retype, allcode, allcode a2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE retype.actype = substr(regrplnk.reacctno,11,4) AND CF.CUSTID=regrplnk.CUSTID
        AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
        AND allcode.cdtype= 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
        AND nvl(clstxdate - 1,todate) >= VF_DATE AND frdate <= VT_DATE
        --NGOCVTT edit bo vai tro trưc tiep, chi hien thi truong phong khi trung lap moi gioi trong nhom
        AND regrplnk.custid NOT IN (SELECT regrp.custid FROM  regrp
        WHERE regrp.effdate <= VT_DATE AND regrp.expdate >= VF_DATE AND regrp.AUTOID=regrplnk.refrecflnkid)
    UNION
    SELECt RE.autoid ma_nhom, RE.custid, RE.custid||RE.actype ma_moi_gioi, nvl(RE.effdate,'30-Dec-1899') ngay_vao_nhom, nvl(RE.expdate,'30-Dec-1899') ngay_ra_nhom, 'Truong phong' vi_tri 
    FROM regrp RE,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
    WHERE RE.effdate <= VT_DATE AND RE.expdate >= VF_DATE AND RE.CUSTID=CF.CUSTID
    ) broker
    --ThangNV: Them code hien thi MOI_GIOI_CHA tuong ung (nhom cha)
    LEFT JOIN
    (SELECT AUTOID MA,PRNAME MOI_GIOI_CHA, MAPLEVEL FROM
        (SELECT GRP.AUTOID, PRGRP.FULLNAME PRNAME, GRP.FULLNAME, A0.CDCONTENT DESC_STATUS,
            SP_FORMAT_REGRP_MAPCODE(GRP.AUTOID) MAPCODE, SP_FORMAT_REGRP_GRPLEVEL(GRP.AUTOID) MAPLEVEL
            FROM REGRP GRP, ALLCODE A0, REGRP PRGRP, RETYPE TYP, RECFLNK RF
            WHERE GRP.ACTYPE=TYP.ACTYPE  AND A0.CDTYPE='RE' AND A0.CDNAME='STATUS' AND A0.CDVAL=GRP.STATUS
            AND GRP.PRGRPID = PRGRP.AUTOID (+) AND GRP.CUSTID=RF.CUSTID AND SP_FORMAT_REGRP_GRPLEVEL(GRP.AUTOID) <> 1)) RE_DAD
    ON BROKER.MA_NHOM = RE_DAD.MA

    LEFT JOIN
    (SELECT autoid, fullname nhom, SP_FORMAT_REGRP_MAPCODE(autoid) cap FROM regrp) grp
    ON broker.ma_nhom = grp.autoid
    LEFT JOIN
    (SELECT custid, fullname ten_moi_gioi FROM cfmast) cf
    ON broker.custid = cf.custid
WHERE cap LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
AND (V_GROUPCUSTID LIKE V_STRBRID OR instr(V_STRBRID,V_GROUPCUSTID)<> 0)
ORDER BY cap, vi_tri DESC
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
