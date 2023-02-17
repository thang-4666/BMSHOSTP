SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0093" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SEARCHDATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2
 )
IS
--bao cao So luong tai khoan theo moi gioi
--created by Chaunh at 13/01/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    V_SEARCHDATE date;
    V_GROUPID varchar2(4);
    V_NUMBER varchar2(4);
    V_GROUPNAME varchar2(50);
    V_LEADERNAME varchar2(50);
    V_GROUPCUSTID varchar2(50);
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

      IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;

   V_SEARCHDATE := to_date(SEARCHDATE, 'dd/MM/RRRR');
   IF GROUPID <> 'ALL' THEN
    BEGIN
        SELECT nvl(cf.fullname,' ') INTO V_LEADERNAME FROM regrp g,  cfmast cf WHERE cf.custid = g.custid AND g.autoid LIKE  V_GROUPID ;
        SELECT recflnk.brid INTO V_GROUPCUSTID FROM regrp g, recflnk  WHERE  g.autoid LIKE  V_GROUPID AND g.custid = recflnk.custid;
        SELECT nvl(fullname,' ') INTO V_GROUPNAME FROM regrp WHERE autoid like V_GROUPID;
        SELECT nvl(count(*) - 1,0) INTO V_NUMBER FROM regrp g WHERE SP_FORMAT_REGRP_MAPCODE(autoid) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' ;
    END;
   ELSE
    BEGIN
        V_LEADERNAME:= 'ALL';
        V_GROUPNAME:= 'ALL';
        V_GROUPCUSTID := 'ALL';
        SELECT count(*) INTO V_NUMBER FROM regrp g;
    END;
   END IF;
   ------------------------------


OPEN PV_REFCURSOR FOR
SELECT ten_mg, custodycd_mg, grp.custid custid_mg,  nvl(BR,0), nvl(RD,0), nvl(RM,0), nvl(AE,0), nvl(DG,0),
       ten_nhom, CASE WHEN vitri.custid IS NOT NULL THEN 'Truong nhom' ELSE 'CVMG - '||ma_nhom END chuc_vu,
       ma_nhom, V_NUMBER so_nhom_vien, V_GROUPNAME ten_nhom_1, CASE WHEN V_GROUPID = '%' THEN ' ' ELSE V_GROUPID END  ma_nhom_1, V_SEARCHDATE ngay_tra_cuu, V_LEADERNAME ten_truong_nhom
FROM(SELECT  regrplnk.custid custid, regrp.fullname ten_nhom,
            SP_FORMAT_REGRP_MAPCODE(regrp.autoid) sorty, regrp.autoid ma_nhom
    FROM regrp, regrplnk,  cfmast CFMAST,
     retype, allcode, allcode a2
    WHERE regrp.autoid = regrplnk.refrecflnkid
    AND substr(regrplnk.reacctno,11,4) = retype.actype
    AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
    AND allcode.cdtype = 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
    AND cfmast.custid = regrplnk.custid
    AND (V_GROUPCUSTID LIKE V_STRBRID OR instr(V_STRBRID,V_GROUPCUSTID)<> 0)
    AND nvl(regrplnk.clstxdate - 1, regrplnk.todate) >= V_SEARCHDATE AND regrplnk.frdate <= V_SEARCHDATE
    AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END )
    GROUP BY regrplnk.custid, regrp.fullname, SP_FORMAT_REGRP_MAPCODE(regrp.autoid), regrp.autoid
    UNION  -- truong nhom
    SELECT cfmast.custid custid, regrp.fullname ten_nhom,
    SP_FORMAT_REGRP_MAPCODE(regrp.autoid) sorty, regrp.autoid ma_nhom
    FROM  cfmast cfmast, regrp
    WHERE regrp.custid = cfmast.custid
     AND (V_GROUPCUSTID LIKE V_STRBRID OR instr(V_STRBRID,V_GROUPCUSTID)<> 0)
    AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END )
    ) grp
    LEFT JOIN
    (SELECT regrplnk.custid custid_mg, regrplnk.refrecflnkid,
            sum(CASE WHEN retype.rerole = 'BM' THEN 1 ELSE 0 end) BR, --moi gioi
            sum(CASE WHEN retype.rerole = 'RD' THEN 1 ELSE 0 END) RD, --nguoi gioi thieu
            sum(CASE WHEN retype.rerole = 'RM' THEN 1 ELSE 0 END) RM, -- cham soc tai khoan (cong tac vien)
            sum(CASE WHEN retype.rerole = 'AE' THEN 1 ELSE 0 END) AE, --nhan vien back
            sum(CASE WHEN retype.rerole = 'DG' THEN 1 ELSE 0 END) DG, --cham soc ho
            count(reaflnk.afacctno)
        FROM regrplnk, reaflnk, retype
        WHERE reaflnk.reacctno = regrplnk.reacctno  AND SP_FORMAT_REGRP_MAPCODE(regrplnk.refrecflnkid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END )
        AND regrplnk.frdate <= V_SEARCHDATE AND nvl(regrplnk.clstxdate - 1, regrplnk.todate) >= V_SEARCHDATE
        AND reaflnk.frdate <= V_SEARCHDATE AND nvl(reaflnk.clstxdate - 1, reaflnk.todate) >= V_SEARCHDATE
        AND retype.actype = substr(regrplnk.reacctno,11,4)
        GROUP BY regrplnk.custid, regrplnk.refrecflnkid) amt
    ON grp.custid = amt.custid_mg AND SP_FORMAT_REGRP_MAPCODE(amt.refrecflnkid)= SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom)
    LEFT JOIN
    (SELECT fullname ten_mg, nvl(custodycd,'N/A') custodycd_mg, custid FROM cfmast) cf
    ON grp.custid = cf.custid
    LEFT JOIN
    (SELECT * FROM regrp ) vitri
    ON vitri.custid = grp.custid AND grp.ma_nhom = vitri.autoid
ORDER BY sorty, chuc_vu DESC
/*SELECT ten_mg, custodycd_mg, custid_mg,  nvl(BR,0), nvl(RD,0), nvl(RM,0), nvl(AE,0), nvl(DG,0),
       ten_nhom, chuc_vu, ma_nhom, V_NUMBER so_nhom_vien, V_GROUPNAME ten_nhom_1, V_GROUPID ma_nhom_1, V_SEARCHDATE ngay_tra_cuu, V_LEADERNAME ten_truong_nhom
FROM
    (SELECT custid custid_mg, autoid FROM recflnk WHERE status = 'A') mg
    left JOIN
    (SELECT  refrecflnkid,
        count(CASE rerole  WHEN 'BM' THEN substr(reacctno, 11,4) END) BR,
        count(CASE rerole  WHEN 'RD' THEN substr(reacctno, 11,4) END) RD,
        count(CASE rerole  WHEN 'RM' THEN substr(reacctno, 11,4) END) RM,
        count(CASE rerole  WHEN 'AE' THEN substr(reacctno, 11,4) END) AE,
        count(CASE rerole  WHEN 'DG' THEN substr(reacctno, 11,4) END) DG
        FROM reaflnk, retype
        WHERE substr(reacctno,11,4) = retype.actype
        AND nvl(clstxdate - 1, todate) >= V_SEARCHDATE
        AND frdate <= V_SEARCHDATE
        GROUP BY refrecflnkid) kh
    ON mg.autoid = kh.refrecflnkid
    LEFT JOIN
    (SELECT fullname ten_mg, nvl(custodycd,'N/A') custodycd_mg, custid FROM cfmast) cf
    ON mg.custid_mg = cf.custid
    inner JOIN
    (SELECT regrplnk.custid custid, regrp.fullname ten_nhom,
            (CASE WHEN regrplnk.custid = regrp.custid THEN 'Truong nhom' ELSE to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent) END) chuc_vu,
            SP_FORMAT_REGRP_MAPCODE(regrp.autoid) ma_nhom
    FROM regrp, regrplnk, cfmast, retype, allcode, allcode a2
    WHERE regrp.autoid = regrplnk.refrecflnkid
    AND substr(regrplnk.reacctno,11,4) = retype.actype
    AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
    AND allcode.cdtype = 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
    AND cfmast.custid = regrplnk.custid
    AND nvl(regrplnk.clstxdate - 1, regrplnk.todate) >= V_SEARCHDATE
    AND regrplnk.frdate <= V_SEARCHDATE
    AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
    UNION ALL -- truong nhom
    SELECT cfmast.custid custid, regrp.fullname ten_nhom, 'Truong nhom' chuc_vu, SP_FORMAT_REGRP_MAPCODE(regrp.autoid) ma_nhom
    FROM cfmast, regrp--, recflnk
    WHERE regrp.custid = cfmast.custid
    --AND cfmast.custid = recflnk.custid
    AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' ) grp
    ON grp.custid = mg.custid_mg
ORDER BY ma_nhom, chuc_vu DESC*/
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
