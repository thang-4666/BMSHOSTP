SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0012_1 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2,
   PV_TLID          IN      varchar2
 )
IS
--bao cao danh sach moi gioi
--created by Chaunh at 16/01/2012
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID          VARCHAR2 (40);      -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    V_CUSTID VARCHAR2(10);

    V_CURRDATE DATE;

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

   select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

   SELECT nvl(custid,' ') INTO V_CUSTID FROM regrp  WHERE regrp.autoid = V_GROUPID ;
    OPEN PV_REFCURSOR FOR

        select MG.ten_moi_gioi, MG.ma_moi_gioi, MG.vi_tri, MG.chuc_vu, MG.nhom, MG.ma_nhom,
            MG.cap, MG.doanh_so, MG.phi_thuc_thu, MG.phi_giam_tru, MG.orderid, CF.ten_kh,
            CF.cust_kh, CF.execamt, CF.feeacr
        from
        (
        SELECT cf.fullname ten_moi_gioi, tran.acctno ma_moi_gioi ,
                grp.vi_tri vi_tri,
                CASE WHEN tran.inttype = 'IBR' THEN  'Truong phong'
                     WHEN retype.rerole = 'BM' THEN to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent)
                     ELSE allcode.cdcontent /*|| ' - ' || to_char(retype.actype)*/ END chuc_vu,
                regrp.fullname nhom, grp.ma_nhom ma_nhom, grp.frdate ngay_vao_nhom, grp.todate ngay_ra_nhom,
                SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) cap,
                sum(tran.intbal) doanh_so,
                sum(tran.intamt) phi_thuc_thu,
                sum(tran.rfmatchamt + tran.rffeeacr) phi_giam_tru,
                CASE WHEN retype.rerole = 'BM' THEN 1
                     WHEN retype.rerole = 'RM' THEN 2
                     WHEN retype.rerole = 'AE' THEN 3
                     WHEN retype.rerole = 'RD' THEN 4
                     ELSE 0
                END orderid
        FROM
        (SELECT * FROM reinttrana union ALL SELECT * FROM reinttran) tran,
        (
        SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrp
        UNION all
        SELECT autoid ma_nhom, custid||actype acctno, custid, effdate frdate, expdate todate, 'Truong phong' vi_tri FROM regrphist
        UNION all
        SELECT refrecflnkid ma_nhom, reacctno acctno, custid, frdate, nvl(clstxdate - 1,todate) todate, 'Nhan vien' vi_tri  FROM regrplnk
        ) grp,
        CFMAST cf, retype, allcode, allcode a2, regrp, recflnk, reaflnk al, reuserlnk ul
        where  grp.acctno = tran.acctno
        AND tran.todate >= VF_DATE AND tran.todate <= VT_DATE
        AND grp.frdate <= tran.todate AND grp.todate >= tran.todate
        AND V_CUSTID = recflnk.custid
        AND ul.tlid = PV_TLID
        and al.refrecflnkid = recflnk.autoid
        AND ul.refrecflnkid = recflnk.autoid
        AND cf.custid = grp.custid AND retype.actype = substr(grp.acctno,11,4)
        AND a2.cdtype = 'RE' AND a2.cdname = 'AFSTATUS' AND a2.cdval = retype.afstatus
        AND allcode.cdtype= 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
        AND regrp.autoid = grp.ma_nhom
        --AND grp.ma_nhom LIKE V_GROUPID
        AND SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom) LIKE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%'
        GROUP BY cf.fullname , tran.acctno ,
                grp.vi_tri ,retype.rerole,
                regrp.fullname , grp.ma_nhom , grp.frdate , grp.todate,
                CASE WHEN tran.inttype = 'IBR' THEN  'Truong phong'
                     WHEN retype.rerole = 'BM' THEN to_char(allcode.cdcontent)||' - '||to_char(a2.cdcontent)
                     ELSE allcode.cdcontent END
        ORDER BY SP_FORMAT_REGRP_MAPCODE(grp.ma_nhom), grp.vi_tri,
                CASE WHEN retype.rerole = 'BM' THEN 1
                     WHEN retype.rerole = 'RM' THEN 2
                     WHEN retype.rerole = 'AE' THEN 3
                     WHEN retype.rerole = 'RD' THEN 4
                     ELSE 0 END
        ) MG,
        (select * from (
            SELECT kh.reacctno so_tk_MG, cf1.fullname ten_kh,/* mg.autoid, */cf1.custodycd cust_kh,rec.refrecflnkid MA_NHOM,
                sum(od.execamt) execamt, sum(od.feeacr) feeacr
            FROM reaflnk kh, recflnk mg,regrplnk reC,
                afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1,
                  (
                    SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmast WHERE deltd <> 'Y'
                        and txdate = V_CURRDATE
                    /*UNION ALL
                    SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmasthist WHERE deltd <> 'Y'*/
                ) OD

            WHERE kh.refrecflnkid = mg.autoid and mg.autoid=reC.autoid
                AND OD.afacctno = af.acctno
                AND (CASE WHEN VF_DATE >= kh.frdate THEN VF_DATE ELSE kh.frdate end) <= OD.txdate
                AND (CASE WHEN VT_DATE <= kh.todate THEN VT_DATE ELSE kh.todate END) >= OD.txdate
                AND kh.deltd <> 'Y'
                AND OD.txdate < nvl(kh.clstxdate ,'01-Jan-2222')
                AND cf1.custid = af.custid AND af.custid = kh.afacctno
                and VF_DATE <= kh.todate
                AND VT_DATE >= kh.frdate
            group by kh.reacctno , cf1.fullname , mg.autoid, cf1.custodycd,rec.refrecflnkid
            union all
           /* SELECT lg.reacctno||lg.reactype so_tk_MG, cf.fullname ten_kh, cf.custodycd cust_kh,
                sum(lg.amt) execamt, sum(lg.freeamt) feeacr
            from reaf_log lg, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
            where lg.txdate >= VF_DATE and lg.txdate <= VT_DATE
                and lg.afacctno = af.acctno and af.custid = cf.custid
            group by lg.reacctno||lg.reactype , cf.fullname , cf.custodycd*/
              SELECT lg.reacctno||lg.reactype so_tk_MG, cf.fullname ten_kh, cf.custodycd cust_kh,rec.refrecflnkid ma_nhom,
                sum(lg.amt) execamt, sum(lg.freeamt) feeacr
            from reaf_log lg, afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,regrplnk rec
            where lg.txdate >= VF_DATE and lg.txdate <= VT_DATE
                and lg.reacctno||lg.reactype=rec.reacctno and lg.afacctno = af.acctno and af.custid = cf.custid
                AND rec.frdate <= lg.txdate AND rec.todate >= lg.txdate and lg.txdate < nvl(rec.clstxdate ,'01-Jan-2222')
           group by lg.reacctno||lg.reactype , cf.fullname , cf.custodycd ,rec.refrecflnkid
            ) where execamt+feeacr<>0
        ) CF
        where MG.ma_moi_gioi = CF.so_tk_MG(+) AND MG.MA_NHOM=CF.MA_NHOM(+)

;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
