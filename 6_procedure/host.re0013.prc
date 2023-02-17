SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0013" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2,
   GROUPID        IN       VARCHAR2
 )
IS
--bao cao gia tri giao dich
--created by Chaunh at 11/01/2012
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);

   VF_DATE DATE;
   VT_DATE DATE;
   V_CUSTID varchar2(10);
   V_GROUPID varchar2(10);

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

   -----------------------
   IF (UPPER(CUSTID) = 'ALL' OR CUSTID IS NULL) THEN
        V_CUSTID := '%';
   ELSE
        V_CUSTID := UPPER(CUSTID);
   END IF;

   IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;

   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR FOR
select MAIN.custid, MAIN.ACCTNO, MAIN.FULLNAME, MAIN.DESC_RETYPE, MAIN.DESC_REROLE,
    MAIN.tong_gia_tri_gd, MAIN.phi_giamtru, MAIN.doanh_thu, MAIN.hoa_hong,
    (nvl(MAIN.minincome,0)) salary, PHU.tong_salary, main.cap,MAIN.TENNHOM,
    (CASE WHEN MAIN.RETYPE='D' THEN 'B' ELSE 'A' END ) TYPE
from
(
SELECT mst.custid, MST.ACCTNO, CF.FULLNAME,rf.minincome,
        A0.CDCONTENT DESC_RETYPE,  MST.TYPENAME || '-' || A2.CDCONTENT DESC_REROLE,
        SUM(nvl(comm.directacr,0) + nvl(comm.indirectacr,0)) tong_gia_tri_gd,
        SUM(nvl(comm.rffeeacr,0)) phi_giamtru,
        SUM(case when MST.RETYPE = 'D' then nvl(comm.directfeeacr,0) else nvl(comm.indirectfeeacr,0) end ) doanh_thu,  SUM(nvl(comm.commision,0)) hoa_hong        ,
        mst.reacctno, mst.rerole, SP_FORMAT_REGRP_MAPCODE(MST.manhom) cap, MST.RETYPE, RE.FULLNAME TENNHOM
FROM RECFLNK RF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ---RETYPE TYP,
        ALLCODE A0, ALLCODE A2,REGRP RE,
       (select GRP.MOIGIOI acctno, SUBSTR(GRP.MOIGIOI,1,10) custid, SUBSTR(GRP.MOIGIOI,11,4) actype, TYP.RETYPE, TYP.REROLE, TYP.TYPENAME,
              custid || retype reacctno, GRP.MANHOM
        from remast mst, RETYPE TYP,
            (SELECT AUTOID MANHOM,CUSTID||ACTYPE MOIGIOI FROM REGRP
            UNION ALL
            SELECT AUTOID MANHOM,CUSTID||ACTYPE MOIGIOI FROM REGRPHIST
            UNION ALL
            SELECT REFRECFLNKID MANHOM,RE.REACCTNO MOIGIOI FROM REGRPLNK RE, RETYPE RET WHERE RET.ACTYPE=SUBSTR(RE.REACCTNO,11,4)AND RET.RETYPE='D') GRP
            where SUBSTR(GRP.MOIGIOI,11,4) = TYP.ACTYPE
            AND GRP.MOIGIOI=MST.ACCTNO(+)) MST
        left join (select * from recommision where commdate <= VT_DATE AND commdate >= VF_DATE
        ) comm
        on mst.acctno = comm.acctno
    WHERE  MST.CUSTID = CF.CUSTID AND RF.CUSTID = MST.CUSTID AND RE.AUTOID=MST.MANHOM
        AND A0.CDTYPE = 'RE' AND A0.CDNAME = 'RETYPE' AND MST.RETYPE = A0.CDVAL
        AND A2.CDTYPE = 'RE' AND A2.CDNAME = 'REROLE' AND MST.REROLE = A2.CDVAL
        AND MST.custid LIKE V_CUSTID
        AND SP_FORMAT_REGRP_MAPCODE(MST.manhom) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
    GROUP BY mst.custid, MST.ACCTNO, CF.FULLNAME, A0.CDCONTENT ,  MST.TYPENAME || '-' || A2.CDCONTENT,
        mst.reacctno, mst.rerole,rf.minincome,MST.manhom, MST.RETYPE,RE.FULLNAME) MAIN,

   (SELECT SUM(tong_salary) tong_salary, CAP FROM(
SELECT CUSTID, MAX(NVL(minincome,0)) tong_salary, CAP
        FROM (
  SELECT mst.custid,rf.minincome,
               A0.CDCONTENT DESC_RETYPE, SP_FORMAT_REGRP_MAPCODE(GRP.manhom) cap
  FROM RECFLNK RF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  CF,ALLCODE A0,
        (select mst.acctno, mst.custid, mst.actype, TYP.RETYPE, TYP.REROLE, TYP.TYPENAME,
              custid || retype reacctno
        from remast mst, RETYPE TYP
        where MST.ACTYPE = TYP.ACTYPE) MST,

        (SELECT AUTOID MANHOM,CUSTID MOIGIOI FROM REGRP
         UNION ALL
         SELECT AUTOID MANHOM,CUSTID MOIGIOI FROM REGRPHIST
         UNION ALL
         SELECT REFRECFLNKID MANHOM,RE.CUSTID MOIGIOI FROM REGRPLNK RE, RETYPE RET
         WHERE RET.ACTYPE=SUBSTR(RE.REACCTNO,11,4)AND RET.RETYPE='D') GRP
  WHERE  MST.CUSTID = CF.CUSTID AND RF.CUSTID = MST.CUSTID AND GRP.MOIGIOI=MST.CUSTID
        AND A0.CDTYPE = 'RE' AND A0.CDNAME = 'RETYPE' AND MST.RETYPE = A0.CDVAL
        AND MST.custid LIKE V_CUSTID
        AND SP_FORMAT_REGRP_MAPCODE(GRP.manhom) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
        )
        GROUP BY CUSTID, CAP
)
        group by CAP) PHU
WHERE MAIN.CAP=PHU.CAP(+)

ORDER BY MAIN.cap,main.DESC_RETYPE ;

 --NGOCVTT EDIT LUONG TOI THIEU, BO COT SALARY
/*) mst
left join
(
    SELECT isdg, custid || retype reacctno, sum(nvl(salary,0)) salary
    FROM resalary
    where (commdate >= VF_DATE AND commdate <= VT_DATE)
    group by custid || retype, isdg
) resa
on  mst.reacctno = resa.reacctno
and (case when mst.rerole = 'DG' then 'Y' else 'N' end) = resa.isdg*/



EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
