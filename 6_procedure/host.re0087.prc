SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0087" (
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
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID          VARCHAR2 (40);    -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    V_CUSTID VARCHAR2(10);

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
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

   SELECT nvl(custid,' ') INTO V_CUSTID FROM regrp  WHERE regrp.autoid = V_GROUPID ;
OPEN PV_REFCURSOR FOR

SELECT cf.fullname ten_moi_gioi, tran.acctno ma_moi_gioi , SP_FORMAT_REGRP_MAPCODE(V_GROUPID) TRUONG_NHOM,
        --CASE WHEN tran.inttype = 'IBR' THEN  'Truong phong'
        --     ELSE 'Moi gioi' END  vi_tri ,
        grp.vi_tri vi_tri,
        CASE WHEN tran.inttype = 'IBR' THEN  'Truong phong'
             WHEN retype.rerole = 'BM' THEN to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent)
             ELSE allcode.cdcontent || ' - ' || to_char(retype.actype) END chuc_vu,
        regrp.fullname nhom, grp.ma_nhom ma_nhom, grp.frdate ngay_vao_nhom, grp.todate ngay_ra_nhom,
        SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) cap, substr(V_CUSTID,1,4), V_STRBRID,
        sum(--CASE WHEN tran.frdate <> tran.todate AND VF_DATE > tran.frdate THEN round(tran.intbal /(tran.todate- tran.frdate)* (tran.todate - VF_DATE + 1),2)
            --     WHEN tran.frdate <> tran.todate AND VT_DATE < tran.todate THEN round(tran.intbal /(tran.todate - tran.frdate)* (VT_DATE - tran.frdate),2)
            --    ELSE tran.intbal
            --     END
                tran.intbal ) doanh_so,
        sum(--CASE WHEN tran.frdate <> tran.todate AND VF_DATE > tran.frdate THEN round(tran.intamt /(tran.todate- tran.frdate)* (tran.todate - VF_DATE + 1),2)
            --     WHEN tran.frdate <> tran.todate AND VT_DATE < tran.todate THEN round(tran.intamt /(tran.todate - tran.frdate)* (VT_DATE - tran.frdate),2)
            --     ELSE tran.intamt
            --     END
                 tran.intamt ) phi_thuc_thu,
        sum( tran.rfmatchamt + tran.rffeeacr ) phi_giam_tru,
        CASE WHEN retype.rerole = 'BM' THEN 01
             WHEN retype.rerole = 'RM' THEN 02
             WHEN retype.rerole = 'AE' THEN 03
             WHEN retype.rerole = 'RD' THEN 04
             ELSE 05
        END orderid
FROM
(SELECT * FROM reinttrana union ALL SELECT * FROM reinttran) tran,
(SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrp
UNION all
SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrphist
UNION all
SELECT RE.refrecflnkid ma_nhom, RE.reacctno acctno, RE.custid, frdate, nvl(RE.clstxdate - 1,RE.todate) todate, 'Nhan vien' vi_tri
 FROM regrplnk RE, RETYPE RET WHERE RET.ACTYPE=SUBSTR(RE.REACCTNO,11,4) AND RET.RETYPE='D'
) grp,
 (SELECT * FROM CFMAST /*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/) cf,
  retype, allcode, allcode a2, regrp, recflnk
where  grp.acctno = tran.acctno
AND tran.todate >= VF_DATE AND tran.todate <= VT_DATE
AND grp.frdate <= tran.todate AND grp.todate >= tran.todate
AND V_CUSTID = recflnk.custid
AND cf.custid = grp.custid AND retype.actype = substr(grp.acctno,11,4)
AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
AND allcode.cdtype= 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
AND regrp.autoid = grp.ma_nhom
AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
AND SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
GROUP BY cf.fullname , tran.acctno ,
        grp.vi_tri ,retype.rerole,
        regrp.fullname , grp.ma_nhom , grp.frdate , grp.todate,
        CASE WHEN tran.inttype = 'IBR' THEN  'Truong phong'
             WHEN retype.rerole = 'BM' THEN to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent)
             ELSE allcode.cdcontent || ' - ' || to_char(retype.actype) END
ORDER BY SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom), grp.vi_tri,
        CASE WHEN retype.rerole = 'BM' THEN 01
             WHEN retype.rerole = 'RM' THEN 02
             WHEN retype.rerole = 'AE' THEN 03
             WHEN retype.rerole = 'RD' THEN 04
             ELSE 05
        END
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
