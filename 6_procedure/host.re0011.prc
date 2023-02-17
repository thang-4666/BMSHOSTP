SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0011" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   RECUSTODYCD    IN       VARCHAR2
 )
IS
--bao cao gia tri giao dich truc tiep - nhom
--created by Chaunh at 18/01/2012
--14/03/2012 repair
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (5);

   VF_DATE          DATE;
   VT_DATE          DATE;
   V_STRCUSTODYCD   VARCHAR2(20);


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


   IF (upper(RECUSTODYCD) = 'ALL' or LENGTH(RECUSTODYCD) < 1)  THEN
    V_STRCUSTODYCD := '%';
   ELSE
    V_STRCUSTODYCD := UPPER(RECUSTODYCD);
   END IF;

   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

OPEN PV_REFCURSOR FOR

select DISTINCT mst.frdate, mst.so_tk_kh, mst.so_tk_MG,
    mst.opndate, mst.todate, mst.ten_kh, mst.ten_mg, mst.afstatus, mst.rerole,
    mst.cust_kh, mst.custid_mg, mst.retype, mst.typename, re.fullname
from
(
SELECT kh.frdate frdate, kh.afacctno so_tk_kh, mg.custid, kh.reacctno so_tk_MG,
    NVL(CF1.opndate,cf1.activedate) opndate, kh.todate,
    cf1.fullname ten_kh, cf2.fullname ten_mg, RETYPE.afstatus, retype.rerole,
    cf1.custodycd cust_kh, cf2.custid custid_mg, retype.actype retype, retype.typename, re.fromre fromre
FROM recflnk mg, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1,
 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf2, retype ,
    reaflnk kh left join
    (
        select re.autoid, re.refrecflnkid, re.reacctno fromre, re.afacctno, re.frdate, re.todate, re.clstxdate, re.status,
            fn_get_autoid_previous(clstxdate,clstxnum) tore
        from reaflnk re
        where fn_get_autoid_previous(clstxdate,clstxnum) <> 'E'
        order by re.frdate
    ) re
    on kh.reacctno||to_char(kh.frdate,'DD/MM/RRRR')||to_char(kh.todate,'DD/MM/RRRR') = re.tore and kh.afacctno = re.afacctno
WHERE kh.refrecflnkid = mg.autoid
    AND kh.deltd <> 'Y'
    AND cf1.custid = af.custid AND af.custid = kh.afacctno
    AND cf2.custid = mg.custid
    AND substr(kh.reacctno, 11,4) = retype.actype
    and mg.custid like V_STRCUSTODYCD
    and kh.frdate >= VF_DATE
    and kh.frdate <=  VT_DATE
) mst
left join
(
    select re.reacctno, cf.fullname
    from reaflnk re, recflnk mg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    where re.refrecflnkid = mg.autoid
        and mg.custid = cf.custid
) re
on mst.fromre = re.reacctno
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
