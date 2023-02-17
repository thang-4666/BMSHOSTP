SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0091" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   --INMONTH          IN      VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2,
   REROLE         IN       VARCHAR2
 )
IS
--bao cao gia tri giao dich phan bo chung
--created by Chaunh at 11/01/2012
--remake by Chaunh at 31/08/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_CUSTID varchar2(20);
    V_REROLE varchar2(20);
    V_ROLENAME varchar2(50);
    V_TEN varchar2(50);
    V_TENNHOM varchar2(50);
    V_TENTRUONGNHOM varchar2(50);
     V_GTGD number(20);
      V_TONG_THU_NHAP number(20);
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

    /*IF TO_NUMBER(SUBSTR(INMONTH,1,2)) <= 12 THEN
        VF_DATE := TO_DATE('01/' || SUBSTR(INMONTH,1,2) || '/' || SUBSTR(INMONTH,3,4),'DD/MM/YYYY');
    ELSE
        VF_DATE := TO_DATE('31/12/9999','DD/MM/YYYY');
    END IF;
    VT_DATE := LAST_DAY(VF_DATE);*/
    VF_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
        VT_DATE := TO_DATE(T_DATE,'DD/MM/YYYY');

   ------------------------
   IF (REROLE = 'ALL') or REROLE is null or REROLE = ''
   THEN
    V_REROLE := '%';
    V_ROLENAME := ' ';
   ELSE
    V_REROLE := REROLE;
    SELECT allcode.cdcontent INTO V_ROLENAME FROM  allcode WHERE  allcode.cdname = 'REROLE' AND allcode.cdtype = 'RE' AND allcode.cdval like V_REROLE ;
   END IF;
   -----------------------
   IF (CUSTID = 'ALL') or CUSTID is null or CUSTID = ''
   THEN
    V_CUSTID := '%';
    V_TEN := ' ';
    V_ROLENAME := ' ';
    V_TENNHOM := ' ';
    V_TENTRUONGNHOM := ' ';
   ELSE
    BEGIN
        V_CUSTID := CUSTID;
        SELECT nvl(cfmast.fullname,' ') INTO V_TEN FROM (SELECT * FROM CFMAST ) cfmast WHERE cfmast.custid like V_CUSTID;
        SELECT ten_nhom, ten_truong_nhom INTO  V_TENNHOM, V_TENTRUONGNHOM
        FROM
        ( SELECT  max(regrp.autoid) ,regrp.fullname ten_nhom,  cfmast.fullname ten_truong_nhom --
            FROM regrp, regrplnk,(SELECT * FROM CFMAST ) cfmast
            WHERE regrp.autoid = regrplnk.refrecflnkid AND regrplnk.custid like V_CUSTID

            AND cfmast.custid = regrp.custid
            GROUP BY regrp.fullname,  cfmast.fullname);
    END ;
   END IF;
   V_TENNHOM := nvl(V_TENNHOM,' ');
   V_TENTRUONGNHOM := nvl(V_TENTRUONGNHOM, ' ');
   V_ROLENAME :=  nvl(V_ROLENAME, ' ');
   V_REROLE := nvl(V_REROLE, ' ');
   V_TEN := nvl(V_TEN, ' ');
   --GT GD and Tong thu nhap
   SELECT  sum(nvl(directacr,0) - nvl(lmn,0)) gtgd,
          sum(nvl(com.commision,0)) + max(nvl(com.minincome,0)) hh
   INTO V_GTGD, V_TONG_THU_NHAP
   FROM recommision com
   WHERE com.commdate >= VF_DATE AND com.commdate <= VT_DATE
   AND custid  = V_CUSTID
    ;

OPEN PV_REFCURSOR FOR

SELECT a.fullname ten_mg, sum(a.gtgdth) amt, sum(a.luong_bo_sung) luong_bo_sung, sum(b.sl_kh) sl_kh,
        --round(a.gtgdth/decode(c.directacr,0,0.000001,c.directacr),4)*100 ty_le_th,
        round(sum(a.gtgdth)/V_GTGD,4) * 100 ty_le_th,
        V_TEN name, V_REROLE rerole, V_ROLENAME chuc_vu, V_TENNHOM ten_nhom, V_TENTRUONGNHOM truong_nhom,
        V_GTGD GTGD, V_TONG_THU_NHAP tong_thu_nhap
FROM
(SELECT cf.fullname, re.reacctno,re.commdate, re.orgreacctno,
        sum(re.matchamt) gtgdth,
        sum(nvl(re.salary,0)+ nvl(re.commision,0)) luong_bo_sung
FROM rerevdg re, (SELECT * FROM CFMAST) cf, retype
WHERE substr(re.orgreacctno,1,10) = V_CUSTID
AND substr(re.reacctno,1,10) = cf.custid
AND retype.actype = substr(re.orgreacctno,11,4)
AND retype.rerole like V_REROLE
and re.frdate >= VF_DATE AND re.todate <= VT_DATE
GROUP BY cf.fullname, re.reacctno, re.commdate, re.orgreacctno
) a,
(SELECT reacctno, count(*) sl_kh FROM reaflnk, retype,
 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE substr(orgreacctno,1,10) = V_CUSTID
AND substr(orgreacctno,11,4) =  retype.actype
AND reaflnk.Afacctno=CF.CUSTID
AND retype.rerole LIKE V_REROLE
AND frdate <= VT_DATE AND nvl(clstxdate - 1,todate) >= VF_DATE
GROUP BY reacctno
) b,
(SELECT * FROM recommision com WHERE com.commdate >= VF_DATE AND com.commdate <= VT_DATE
AND custid  = V_CUSTID
)c
WHERE a.reacctno = b.reacctno(+)
AND a.orgreacctno = c.acctno (+)
AND a.commdate = c.commdate (+)
GROUP BY a.fullname, substr(a.orgreacctno,1,10)
;


EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
