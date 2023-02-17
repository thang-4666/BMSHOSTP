SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0087_1"
 (
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

   SELECT nvl(custid,' ') INTO V_CUSTID FROM regrp  WHERE regrp.autoid = V_GROUPID ;
OPEN PV_REFCURSOR FOR

    SELECT max(cf.fullname) ten_moi_gioi, od.reacctno ma_moi_gioi ,
        grp.vi_tri vi_tri,
        CASE --WHEN tran.inttype = 'IBR' THEN  'Truong phong'
             WHEN retype.rerole = 'BM' THEN to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent)
             ELSE allcode.cdcontent || ' - ' || to_char(retype.actype) END chuc_vu,
        max(regrp.fullname) nhom, grp.ma_nhom ma_nhom, grp.frdate ngay_vao_nhom, grp.todate ngay_ra_nhom,
        SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) cap, substr(V_CUSTID,1,4), V_STRBRID,
        sum(od.matchamt) doanh_so,
        sum(od.feeacr) phi_thuc_thu,
        sum(0) phi_giam_tru,
        CASE WHEN retype.rerole = 'BM' THEN 01
             WHEN retype.rerole = 'RM' THEN 02
             WHEN retype.rerole = 'AE' THEN 03
             WHEN retype.rerole = 'RD' THEN 04
             ELSE 05
        END orderid
    FROM
        (SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrp
        UNION all
        SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrphist
        UNION all
        SELECT refrecflnkid ma_nhom, reacctno acctno, custid, frdate, nvl(clstxdate - 1,todate) todate, 'Nhan vien' vi_tri  FROM regrplnk
        ) grp,
        cfmast cf, retype, allcode, allcode a2, regrp, /*recflnk, */
        (
            SELECT x.orderid,x.reacctno, x.brid,y.autoid, y.fullname, x.matchamt, x.feeacr, x.txdate
                FROM (
                        SELECT  OD.orderid, od.execamt matchamt, od.feeacr, od.afacctno, kh.reacctno, od.txdate, recflnk.brid
                                FROM reaflnk kh,  sbsecurities sb,
                                         cfmast cf, afmast af, recflnk,recfdef rf,
                                        (SELECT OD.orderid, od.execamt , od.feeacr, od.afacctno, od.txdate, od.codeid
                                        FROM vw_odmast_all OD
                                        WHERE OD.txdate <=  VT_DATE
                                        AND OD.txdate >=  VF_DATE
                                        AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                                        ) OD
                                WHERE
                                         OD.afacctno = kh.afacctno
                                        AND kh.orgreacctno is NULL --chi lay cho moi gioi chinh
                                        AND od.afacctno = af.acctno AND af.custid = cf.custid
                                        AND sb.codeid = od.codeid
                                        AND sb.tradeplace IN ('001','002','005')
                                        --AND OD.txdate <=  VT_DATE
                                        --AND OD.txdate >=  VF_DATE
                                        AND OD.txdate <= nvl(kh.clstxdate -1 ,kh.todate)
                                        AND od.txdate >= kh.frdate
                                        --AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                                        AND SUBSTR(kh.reacctno,1,10) = recflnk.custid(+)
                                        AND cf.custodycd NOT LIKE '___P%'
                                        AND rf.reactype = substr(kh.reacctno,11,4) AND rf.refrecflnkid = recflnk.autoid
                                        AND rf.effdate <= od.txdate AND rf.expdate >= od.txdate
                                ) x
                            LEFT JOIN
                            (
                             SELECT  OD.orderid,  regrp.autoid, regrp.fullname
                                FROM reaflnk kh, regrplnk nhom, sbsecurities sb,
                                         cfmast cf, afmast af, regrp,
                                        (SELECT OD.orderid, od.execamt , od.feeacr, od.afacctno, od.txdate, od.codeid
                                        FROM vw_odmast_all OD
                                        WHERE OD.txdate <=  VT_DATE
                                        AND OD.txdate >=  VF_DATE
                                        AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                                        ) OD
                                WHERE
                                         OD.afacctno = kh.afacctno
                                        AND kh.orgreacctno is NULL
                                        AND od.afacctno = af.acctno AND af.custid = cf.custid
                                        AND sb.codeid = od.codeid
                                        AND sb.tradeplace IN ('001','002','005')
                                        AND kh.reacctno = nhom.reacctno
                                        --AND OD.txdate <=  VT_DATE
                                        --AND OD.txdate >=  VF_DATE
                                        AND OD.txdate <= nvl(kh.clstxdate -1 ,kh.todate)
                                        AND od.txdate >= kh.frdate
                                        AND OD.txdate <= nvl(nhom.clstxdate -1 ,nhom.todate)
                                        AND od.txdate >= nhom.frdate
                                        --AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                                        AND regrp.autoid = nhom.refrecflnkid
                                        AND cf.custodycd NOT LIKE '___P%'
                                        --AND regrp.autoid = 6
                            ) y
                            ON x.orderid = y.orderid
        ) od
    where  grp.acctno = od.reacctno AND grp.ma_nhom = od.autoid
        AND grp.frdate <= od.txdate AND grp.todate >= od.txdate
        --AND recflnk.custid = V_CUSTID
        AND cf.custid = grp.custid AND retype.actype = substr(grp.acctno,11,4)
        AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
        AND allcode.cdtype= 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
        AND regrp.autoid = grp.ma_nhom
        --AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
        AND (od.brid LIKE V_STRBRID OR instr(V_STRBRID,od.brid)<> 0)
        AND SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
    GROUP BY cf.custid , od.reacctno ,
            grp.vi_tri ,retype.rerole,
            /*regrp.fullname , */grp.ma_nhom , grp.frdate , grp.todate,
            CASE --WHEN tran.inttype = 'IBR' THEN  'Truong phong'
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
