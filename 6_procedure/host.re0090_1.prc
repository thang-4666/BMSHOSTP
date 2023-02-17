SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0090_1" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2,
   PV_TLID        IN       VARCHAR2
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
    V_REERNAME varchar2(50);
    v_doanh_thu_thuan number(20,4);
    v_hoa_hong number(20,4);
    v_luong number(20,4);
    V_tong_luong_dm number(20,4);
    V_DS_DINH_MUC_TT number(20,4);
    V_DM_Kinhdoanh_CS NUMBER(20,4);
    V_DM_dieuchinh number(20,4);
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

   -----------------------
   V_CUSTID := CUSTID;
   IF (CUSTID <> 'ALL')
   THEN
    BEGIN
        V_CUSTID := CUSTID;
        SELECT cf.fullname INTO V_REERNAME FROM cfmast cf WHERE cf.custid like V_CUSTID;
    END ;
   ELSE
    V_CUSTID := '%';
    V_REERNAME := 'ALL';
   END IF;
    VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');
   --tinh doanh so dinh muc truc tiep
   select nvl(max(mindrevamt),0) into V_DS_DINH_MUC_TT
   from recommision
   where commdate =  (select max(commdate) from recommision
                            where custid = V_CUSTID and retype = 'D'
                            --AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
                            and commdate <= VT_DATE and commdate >= VF_DATE )
   and custid = V_CUSTID  and retype = 'D'
   --AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
   and commdate <= VT_DATE and commdate >= VF_DATE;

   --tinh tong luong dinh muc
   select nvl(sum(s),0), nvl(sum(t),0), nvl(sum(k),0) into V_tong_luong_dm, V_DM_Kinhdoanh_CS, V_DM_dieuchinh
   from (
            select  nvl(max(minincome),0) s, nvl(max(mindrevamt),0) t, nvl(max(mindrevamtreal),0) k  ,retype-- into V_tong_luong_dm
            from recommision
            where commdate = (select max(commdate)  from recommision
                                where  custid = V_CUSTID
                                --AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
                                AND commdate >= VF_DATE AND commdate <= VT_DATE
                                )
            and custid = V_CUSTID AND retype = 'D' and isdrev = 'Y'
            --AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
        group by retype
        )


   ;
   --tinh luong
   SELECT nvl(sum(revenue),0) , nvl(sum(commision),0), nvl(sum(salary),0)
    INTO  v_doanh_thu_thuan, v_hoa_hong, v_luong
    FROM resalary
    where custid = V_CUSTID
    AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
    AND commdate >= VF_DATE AND commdate <= VT_DATE;
      ------------------------------

OPEN PV_REFCURSOR FOR
SELECT main.acctno, retype, rerole, typename, so_kh.amt so_luong_tk, V_tong_luong_dm luong_dinh_muc,
       V_DM_Kinhdoanh_CS dm_kd_cs, V_DM_dieuchinh dm_dieuchinh,
        (tong_gia_tri_gd)tong_gia_tri_gd, --+ remast.directacr + remast.indirectacr,
        giam_tru_ds_dm, doanh_thu_thuan,
       (hoa_hong +  nvl(hh.ps_hoahong,0)) hoa_hong, V_DS_DINH_MUC_TT DS_dinhmuc_TT,
       DS_dinhmuc_GT, ds_giamtru, dt_giamtru,
        nvl(icrate,0) icrate, fullname, V_CUSTID custid,
        v_doanh_thu_thuan T_doanh_thu_thuan, v_hoa_hong T_hoa_hong, v_luong T_luong
FROM --remast,
    (SELECT * FROM
        (SELECT acctno, retype, rerole, typename,
                count(acctno) so_luong_tk, sum(luong_dinh_muc) luong_dinh_muc, sum(tong_gia_tri_gd) tong_gia_tri_gd,
                SUM(giam_tru_ds_dm)giam_tru_ds_dm, sum(doanh_thu_thuan) doanh_thu_thuan, sum(hoa_hong) hoa_hong,
                /*sum(DS_dinhmuc_TT) DS_dinhmuc_TT,*/ sum(DS_dinhmuc_GT) DS_dinhmuc_GT, sum(ds_giamtru) ds_giamtru, sum(dt_giamtru) dt_giamtru
            FROM
                (SELECT  comm.custid ma_mg, comm.acctno, cfmast.fullname ten_mg,
                        comm.minincome luong_dinh_muc,
                        comm.mindrevamt DS_dinhmuc_TT,
                        comm.minirevamt DS_dinhmuc_GT,
                        (CASE WHEN comm.retype = 'D' AND re.rerole NOT IN ('RD','DG') THEN '01' --Luong truc tiep
                            WHEN comm.retype = 'I' THEN '03' -- Luong gian tiep
                            WHEN comm.retype = 'D' AND re.rerole = 'RD' THEN  '02' -- Luong gioi thieu
                            ELSE '04' --Luong cham soc ho
                            END ) retype,allcode.cdcontent rerole,
                        (comm.directacr + comm.indirectacr) tong_gia_tri_gd,
                        comm.disrevacr giam_tru_ds_dm,
                        comm.revenue doanh_thu_thuan,
                        comm.commision hoa_hong,
                        comm.rfmatchamt ds_giamtru,  comm.rffeeacr dt_giamtru,
                        re.typename
                    FROM recommision comm, retype re,(SELECT * FROM CFMAST) cfmast, allcode, recflnk,reuserlnk,
                    reaflnk kh, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1
                    WHERE re.actype = comm.reactype
                AND reuserlnk.tlid = PV_TLID
                and kh.refrecflnkid = recflnk.autoid
                AND cf1.custid = kh.afacctno
                AND reuserlnk.refrecflnkid = recflnk.autoid
                AND allcode.cdtype = 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = re.rerole
                AND cfmast.custid = comm.custid
                AND comm.commdate <= VT_DATE AND comm.commdate >= VF_DATE
                AND comm.custid LIKE V_CUSTID
                AND comm.custid = recflnk.custid
                --AND (substr(comm.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(comm.custid,1,4))<> 0)
                --AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
                ORDER BY ma_mg,retype
                )
            GROUP BY acctno, retype, rerole, typename
        ) a
        left JOIN
        (SELECT cfmast.fullname, cfmast.custid FROM (SELECT * FROM CFMAST ) cfmast) cf
        ON cf.custid = substr(a.acctno,1,10)
        LEFT JOIN
        (SELECT actype, icrate FROM iccftypedef WHERE modcode = 'RE' AND ruletype = 'F' --co dinh
            AND ICTYPE = 'P' AND ICRATECD = 'F') icc
        ON icc.actype = substr(a.acctno,11,4)
    ) main
    LEFT JOIN --phat sinh hoa hong
    (SELECT tran.acctno, SUM(CASE WHEN ap.field = 'BALANCE' THEN
                                CASE WHEN ap.txtype = 'D' THEN -tran.namt ELSE tran.namt END
                                ELSE 0
                                END) ps_hoahong

        FROM
        (SELECT * FROM retran where deltd <> 'Y' UNION ALL SELECT * FROM retrana where deltd <> 'Y') tran,
        vw_tllog_all tl, apptx ap
        WHERE tran.txdate = tl.txdate AND  tran.txnum = tl.txnum and tl.deltd <> 'Y'
        AND  tran.txcd = ap.txcd AND apptype = 'RE' AND txtype IN ('C','D') AND ap.field = 'BALANCE' and tl.tltxcd <> '0320'
        AND tran.txdate <= VT_DATE AND tran.txdate >= VF_DATE
        GROUP BY tran.acctno
    )hh
    ON hh.acctno = main.acctno
    left join -- so khach hang cua tai khoan
    (select reacctno, count(*) amt from reaflnk where substr(reacctno,1,10) like V_CUSTID
    AND reaflnk.frdate <= VT_DATE AND nvl(reaflnk.clstxdate - 1, reaflnk.todate) >= VF_DATE
    group by reacctno ) so_kh
    on so_kh.reacctno = main.acctno
--WHERE remast.acctno = main.acctno
;


EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
