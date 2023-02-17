SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0098" (
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
--bao cao phan bo thuong truc tiep moi gioi cham soc tai khoan
--created by Chaunh at 11/09/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    v_ten_nhom varchar2(50);
    v_autoid varchar2(50);
    v_truong_nhom varchar2(50);
    v_T_ds_dinh_muc_nhom number(20,2);
    v_doanh_so_nhom number(20,2);
    v_T_ds_vuot_dm number(20,2);
    v_hh_nhom number(20,2);
    v_slkh NUMBER;

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

   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');


   -- so luong kh trong nhom
   SELECT sum(slkh)  INTO v_slkh FROM
   (
   SELECT nvl(count(*),0) slkh  FROM  regrp, regrplnk, reaflnk, recflnk,
   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)CF1
   WHERE
   regrp.autoid = regrplnk.refrecflnkid
   AND reaflnk.AFACCTNO=CF1.CUSTID
   AND reaflnk.reacctno = regrplnk.reacctno
   AND regrplnk.frdate <= VT_DATE AND nvl(regrplnk.clstxdate - 1, regrplnk.todate) >= VF_DATE
   AND reaflnk.frdate <= VT_DATE AND nvl(reaflnk.clstxdate - 1, reaflnk.todate) >= VF_DATE
   AND regrp.autoid LIKE V_GROUPID
   AND regrp.custid = recflnk.custid
   AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
   GROUP BY regrp.autoid
   UNION ALL
   SELECT 0 slkh FROM dual
   ) ;

   ----
   select ten_nhom, autoid,truong_nhom, nvl(minirevamt,0), nvl(indirectacr,0), nvl(disdirectacr,0), nvl(commision,0)
        INTO v_ten_nhom,
            v_autoid,
            v_truong_nhom,
            v_T_ds_dinh_muc_nhom,
            v_doanh_so_nhom,
            v_T_ds_vuot_dm,
            v_hh_nhom
   from
 (SELECT regrp.custid,regrp.fullname ten_nhom, regrp.autoid, cfmast.fullname truong_nhom
        FROM regrp, cfmast
        WHERE  cfmast.custid = regrp.custid
            AND regrp.autoid LIKE V_GROUPID) gr
 left join
       (select custid, /*sum(minirevamt) minirevamt,*/sum(indirectacr) indirectacr,sum(disdirectacr) disdirectacr,sum(commision) commision
            from recommision
            where retype = 'I' AND commdate <= VT_DATE  AND commdate >= VF_DATE and refrecflnkid = V_GROUPID
            group by custid) comm
 on gr.custid = comm.custid
 left join
       (select minirevamt, custid from recommision where commdate =  (select max(commdate) from recommision where retype = 'I' AND commdate <= VT_DATE  AND commdate >= VF_DATE and refrecflnkid = V_GROUPID)
            and retype = 'I' AND commdate <= VT_DATE  AND commdate >= VF_DATE and refrecflnkid = V_GROUPID) revamt
 on revamt.custid = comm.custid
       ;


OPEN PV_REFCURSOR FOR
SELECT main.*, /*sokh.so_kh,*/ V_GROUPID ma_nhom, v_slkh sl_kh,
        v_ten_nhom ten_nhom, v_autoid autoid, v_truong_nhom truong_nhom,
        v_T_ds_dinh_muc_nhom T_ds_dinh_muc_nhom, v_doanh_so_nhom doanh_so_nhom,v_T_ds_vuot_dm T_ds_vuot_dm, v_hh_nhom hh_nhom
        FROM
    (select commdate, ten_mg, fullname, /*sum(dinh_muc_khoan)*/ dinh_muc_dc, ty_le_dc, ty_le_thuong, thu_tu, typename, sum(gt_gd) gt_gd, sum(doanh_so) doanh_so,
        sum(gtgd_vuotdm) gtgd_vuotdm, sum(ds_vuot_dm) ds_vuot_dm, sum(ds_dinh_muc) ds_dinh_muc,
        sum(hh) hh, luong_dinh_muc, sum(luong_theo_tt_ht) luong_theo_tt_ht, sum(tong_luong) tong_luong
    from (
        SELECT comm.commdate, comm.custid ten_mg, cfmast.fullname, df.odrnum thu_tu,retype.typename typename,
            (comm.mindrevamt) dinh_muc_dc,
             comm.revrate ty_le_dc,
             retype.ratecomm ty_le_thuong,
            sum(comm.directacr + comm.indirectacr) gt_gd,
            sum(round(comm.directacr *comm.commdays/comm.bmdays,2)) doanh_so, --doanh so * ngay trong thang / ngay thuc hien
            sum(comm.disdirectacr ) gtgd_vuotdm,
            sum(comm.disdirectacr)   ds_vuot_dm, sum(disrevacr) ds_dinh_muc,
            sum(comm.commision) hh, comm.minincome luong_dinh_muc,
            -- round(sum(comm.minincome * LEAST(1,GREATEST(comm.minratesal/100,(comm.directacr)/(comm.disrevacr+0.00001))))) luong_theo_tt_ht,
            round((case WHEN  comm.minratesal>0 then round(comm.minincome * LEAST(1,GREATEST(comm.minratesal/100,sum(comm.directacr)/(comm.mindrevamtreal+0.00001))) * comm.bmdays /comm.commdays)
                        WHEN  comm.minratesal=0 AND sum(comm.directacr)>=comm.mindrevamtreal then round(comm.minincome* comm.bmdays /comm.commdays)
                        WHEN  comm.minratesal=0 AND sum(comm.directacr) < comm.mindrevamtreal then 0 end)) luong_theo_tt_ht,
            round((case WHEN  comm.minratesal>0 then round(comm.minincome * LEAST(1,GREATEST(comm.minratesal/100,sum(comm.directacr)/(comm.mindrevamtreal+0.00001))) * comm.bmdays /comm.commdays)
                        WHEN  comm.minratesal=0 AND sum(comm.directacr)>=comm.mindrevamtreal then round(comm.minincome* comm.bmdays /comm.commdays)
                        WHEN  comm.minratesal=0 AND sum(comm.directacr) < comm.mindrevamtreal then 0 end) + comm.commision) tong_luong
         --round(sum(comm.minincome * LEAST(1,GREATEST(comm.minratesal/100,(comm.directacr)/(comm.disrevacr+0.00001))) + comm.commision)) tong_luong -- + comm.commision) tong_luong--, isdrev
        FROM recommision comm, retype,REAFLNK KH,
        (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)CF1, cfmast, regrp, regrplnk, recfdef df, recflnk
        WHERE retype.actype = comm.reactype AND comm.custid = cfmast.custid
        AND KH.REFRECFLNKID=recflnk.AUTOID
        AND KH.AFACCTNO=CF1.CUSTID
        AND comm.commdate <= VT_DATE AND comm.commdate >= VF_DATE
        AND comm.commdate >= regrplnk.frdate AND comm.commdate <= nvl(regrplnk.clstxdate -1,regrplnk.todate)
        AND comm.retype = 'D' and retype.rerole in ('RM')
        AND regrp.autoid = regrplnk.refrecflnkid
        AND regrplnk.reacctno = comm.acctno
        AND comm.refrecflnkid = df.refrecflnkid AND comm.reactype = df.reactype
        AND SP_FORMAT_REGRP_MAPCODE(regrp.autoid) LIKE (CASE WHEN V_GROUPID = '%' THEN '%' ELSE SP_FORMAT_REGRP_MAPCODE(V_GROUPID)||'%' END)
        --AND regrp.autoid LIKE V_GROUPID
        AND recflnk.custid = regrp.custid
        AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
        GROUP BY comm.commdate, comm.custid, cfmast.fullname, comm.retype, comm.mindrevamt,
        comm.minincome, comm.minratesal, comm.saltype, comm.mindrevamtreal, comm.bmdays,
        comm.commdays, comm.commision, comm.revrate, retype.ratecomm, df.odrnum,retype.typename
        )
    group by commdate, ten_mg, fullname,luong_dinh_muc, dinh_muc_dc, ty_le_dc, ty_le_thuong, thu_tu, typename
    ORDER BY thu_tu) main
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
