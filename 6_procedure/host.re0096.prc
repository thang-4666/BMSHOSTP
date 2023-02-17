SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0096" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2,
   REROLE         IN       VARCHAR2
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
    V_GROUPNAME varchar2(50);
    V_GROUPLEADER varchar2(50);
    V_REROLE varchar2(4);
BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

    if (upper(REROLE) = 'ALL') then
    V_REROLE := '%';
    else
    V_REROLE := REROLE;
    end if;


   IF GROUPID <> 'ALL' THEN
      BEGIN
        V_GROUPID := GROUPID;
        SELECT G.FULLNAME, CF.FULLNAME INTO V_GROUPNAME, V_GROUPLEADER FROM regrp g, CFMAST CF
        WHERE  g.autoid LIKE  V_GROUPID AND CF.CUSTID = G.CUSTID ;
      END;
   ELSE
      BEGIN
        V_GROUPID := '%';
        V_GROUPNAME := 'ALL';
        V_GROUPLEADER := 'ALL';
      end;
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');
OPEN PV_REFCURSOR FOR
/*SELECT \*MAIN.*, COM.*, V_GROUPID GROUPID, V_GROUPNAME GROUPNAME, V_GROUPLEADER LEADERNAME*\
tk_mg, ten_mg, ma_nhom, ten_nhom, ma_tn, ten_tn, chuc_vu, sum(gt_gd) gt_gd, sum(giamtru_phatvay) giamtru_phatvay,
sum(giamtru_giaichap) giamtru_giaichap, sum(giamtru_khac) giamtru_khac, sum(gtgd_thuchien) gtgd_thuchien,
sum(thuong_mg) thuong_mg, V_GROUPID GROUPID, V_GROUPNAME GROUPNAME, V_GROUPLEADER LEADERNAME
FROM
(SELECT regrplnk.custid tk_mg, cfmast.fullname ten_mg, regrplnk.reacctno ma_mg,
            regrp.autoid ma_nhom, regrp.fullname ten_nhom, regrp.custid ma_tn, cf2.fullname ten_tn,
            'D' chuc_vu
        FROM regrp, regrplnk, cfmast, cfmast cf2, retype
        WHERE regrp.autoid = regrplnk.refrecflnkid
        AND cfmast.custid = regrplnk.custid
        AND cf2.custid = regrp.custid
        AND regrplnk.frdate <= VT_DATE AND nvl(regrplnk.clstxdate -1,regrplnk.todate) >= VF_DATE
        --AND regrp.autoid like V_GROUPID
        AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
        AND substr(regrplnk.reacctno, 11,4) = retype.actype
        AND retype.rerole LIKE V_REROLE
) MAIN
LEFT JOIN
(SELECT ACCTNO, SUM(NVL(DIRECTACR,0)) GT_GD, SUM(NVL(LMN,0)) GIAMTRU_PHATVAY, SUM(NVL(DISPOSAL,0)) GIAMTRU_GIAICHAP,
       SUM(NVL(RFMATCHAMT,0)) GIAMTRU_KHAC, SUM(NVL(DISDIRECTACR,0)) GTGD_THUCHIEN, SUM(NVL(COMMISION,0)) THUONG_MG
FROM RECOMMISION, retype WHERE COMMDATE <= VT_DATE AND COMMDATE >= VF_DATE
AND reactype = retype.actype AND retype.rerole LIKE V_REROLE
GROUP BY ACCTNO
) COM
ON MAIN.MA_MG = COM.ACCTNO
GROUP BY tk_mg, ten_mg, ma_nhom, ten_nhom, ma_tn, ten_tn, chuc_vu
ORDER BY sp_format_regrp_mapcode(MAIN.MA_NHOM), MAIN.TEN_MG*/

------------------------------------------------------

SELECT  tk_mg, ten_mg, ma_nhom, ten_nhom, chuc_vu, NVL(sum(gt_gd),0) gt_gd, NVL(sum(giamtru_phatvay),0) giamtru_phatvay,
NVL(sum(giamtru_giaichap),0) giamtru_giaichap, NVL(sum(giamtru_khac),0) giamtru_khac, NVL(sum(gtgd_thuchien),0) gtgd_thuchien,
NVL(sum(thuong_mg),0) thuong_mg, V_GROUPID GROUPID, V_GROUPNAME GROUPNAME, V_GROUPLEADER LEADERNAME
FROM
(SELECT  regrplnk.custid tk_mg, cfmast.fullname ten_mg, regrplnk.reacctno ma_mg,
            regrp.autoid ma_nhom, regrp.fullname ten_nhom,
            'D' chuc_vu, to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent) vi_tri
        FROM regrplnk, retype, allcode, allcode a2,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CFMAST ,
         regrp,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF2
        WHERE retype.actype = substr(regrplnk.reacctno,11,4)
        AND regrp.autoid = regrplnk.refrecflnkid
        AND cfmast.custid = regrplnk.custid
        AND cf2.custid = regrp.custid
        AND retype.rerole LIKE V_REROLE
        AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
        AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
        AND allcode.cdtype= 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
          AND nvl(regrplnk.clstxdate - 1,regrplnk.todate) >= VF_DATE AND regrplnk.frdate <= VT_DATE

    UNION ALL
    SELECt regrp.custid tk_mg, cfmast.fullname ten_mg, regrp.custid||regrp.actype ma_mg, regrp.autoid ma_nhom,regrp.FULLNAME ten_nhom, 'D' chuc_vu, 'Truong phong' vi_tri
     FROM regrp,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CFMAST
     WHERE  CFMAST.custid = regrp.custid
     AND regrp.EXPDATE >VT_DATE
      AND regrp.autoid like V_GROUPID
      AND nvl('0123','') LIKE V_REROLE
) MAIN
LEFT JOIN
(SELECT ACCTNO,refrecflnkid, SUM(NVL(DIRECTACR,0)) GT_GD, SUM(NVL(LMN,0)) GIAMTRU_PHATVAY, SUM(NVL(DISPOSAL,0)) GIAMTRU_GIAICHAP,
       SUM(NVL(RFMATCHAMT,0)) GIAMTRU_KHAC, SUM(NVL(DISDIRECTACR,0)) GTGD_THUCHIEN, SUM(NVL(COMMISION,0)) THUONG_MG
FROM RECOMMISION, retype WHERE COMMDATE <= VT_DATE AND COMMDATE >= VF_DATE
AND reactype = retype.actype AND retype.rerole LIKE V_REROLE
GROUP BY ACCTNO,refrecflnkid
) COM
ON MAIN.MA_MG = COM.ACCTNO
GROUP BY tk_mg, ten_mg, ma_nhom, ten_nhom, chuc_vu
ORDER BY sp_format_regrp_mapcode(MAIN.MA_NHOM), MAIN.TEN_MG

;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
