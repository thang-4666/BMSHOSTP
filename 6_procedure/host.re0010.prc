SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0010 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID        IN       VARCHAR2,
   RECUSTODYCD    IN       VARCHAR2,
   REROLE         IN       VARCHAR2
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
   V_GROUPID        VARCHAR2(10);
   V_STRCUSTODYCD   VARCHAR2(20);
   V_STRREROLE      VARCHAR2(20);
   V_CURRDATE       DATE;

BEGIN

SELECT TO_DATE ( '01'|| SUBSTR(VARVALUE,3),'DD/MM/YYYY')  INTO V_CURRDATE
FROM SYSVAR
WHERE GRNAME = 'SYSTEM' AND VARNAME ='CURRDATE';

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF (upper(GROUPID) = 'ALL' or LENGTH(GROUPID) < 1)  THEN
    V_GROUPID := '%';
   ELSE
    V_GROUPID := UPPER(GROUPID);
   END IF;

   IF (upper(RECUSTODYCD) = 'ALL' or LENGTH(RECUSTODYCD) < 1)  THEN
    V_STRCUSTODYCD := '%';
   ELSE
    V_STRCUSTODYCD := UPPER(RECUSTODYCD);
   END IF;

   IF (upper(REROLE) = 'ALL')  THEN
    V_STRREROLE := '%';
   ELSE
    V_STRREROLE := REROLE;
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR') - 1; -- Fix truoc mot ngay lam viec

OPEN PV_REFCURSOR FOR
SELECT * FROM
(
SELECT  GROUPID IN_GROUPID, RECUSTODYCD IN_RECUSTODYCD, REROLE IN_REROLE, to_char(VT_DATE,'DD/MM/RRRR') DEN_NGAY,
    main.so_tk_kh, main.custid, main.so_tk_MG,
    main.ten_kh, main.ten_mg, main.rerole,
    main.cust_kh, main.custid_mg, main.retype, main.BIEU_HH,
    sum(main.execamt) execamt, suM(main.feeacr) feeacr,
    sum(GT_GD) gt_gd, sum(GTGD_THUCHIEN) GTGD_THUCHIEN, sum(GT_PHI) GT_PHI,
    sum(NVL(THUONG_HH,0)) + CASE  when VT_DATE <  V_CURRDATE then 0 else  MAX(MAIN.THUONG_HHDK) end  thuong_mg, reg.ten_truong_nhom, reg.ten_nhom || '_' || reg.ten_truong_nhom ten_nhom,
    reg.reacctno ma_nhom, NVL(reg.autoid,99999) autoid, max(nvl(reg.thuong_nhom,0)) thuong_nhom
FROM
(
---    SELECT kh.afacctno so_tk_kh, mg.custid, kh.reacctno so_tk_MG, kh.frdate, kh.todate,
---        cf1.fullname ten_kh, cf2.fullname ten_mg, retype.afstatus, mg.autoid, retype.rerole,
---        cf1.custodycd cust_kh, mg.custid custid_mg, cf1.activedate activedate, retype.typename retype,
---        od.execamt, od.feeacr, retype.typename || ' _ ' || allcode.cdcontent BIEU_HH/*,
---        (fn_re_commision(kh.reacctno)) THUONG_HHDK*/
---        , MST.THUONG_HHDK
    select tl.afacctno so_tk_kh,mst.custid, mst.custid custid_mg, mst.acctno so_tk_MG, cf.fullname ten_kh,
        cf2.fullname ten_mg, retype.afstatus, retype.rerole, cf.custodycd cust_kh,
        cf.activedate activedate, retype.typename retype,
        sum(tl.amt) execamt, sum(tl.FREEAMT) feeacr, retype.typename || ' _ ' || allcode.cdcontent BIEU_HH,
        max(mst.recommision) THUONG_HHDK
    from reaf_log tl, REMAST mst,
     cfmast cf, afmast af,
      (SELECT * FROM CFMAST ) cf2,
        retype, allcode
    where tl.reacctno = mst.custid and tl.reactype = mst.actype
        and tl.afacctno = af.acctno and cf.custid = af.custid
        and mst.custid = cf2.custid
        and mst.actype = retype.actype
        and allcode.cdtype = 'RE' and allcode.cdname = 'REROLE' and allcode.cdval = retype.rerole
        AND retype.rerole LIKE V_STRREROLE
        AND cf2.custid LIKE V_STRCUSTODYCD
        and VF_DATE <= tl.txdate
        AND VT_DATE >= tl.txdate
    group by tl.afacctno ,mst.custid, mst.custid , mst.acctno , cf.fullname ,
        cf2.fullname , retype.afstatus, retype.rerole, cf.custodycd ,
        cf.activedate , retype.typename ,
        retype.typename || ' _ ' || allcode.cdcontent
    /*FROM reaflnk kh, recflnk mg, (SELECT RE.ACCTNO, fn_re_commision(RE.ACCTNO ) THUONG_HHDK  FROM REMAST RE) MST,
        afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf2, retype, allcode,
        (
            SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmast WHERE deltd <> 'Y'
            UNION ALL
            SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmasthist WHERE deltd <> 'Y'
        ) OD
    WHERE kh.refrecflnkid = mg.autoid
        AND OD.afacctno = af.acctno
        AND KH.REACCTNO = MST.ACCTNO
        AND (CASE WHEN VF_DATE >= kh.frdate THEN VF_DATE ELSE kh.frdate end) <= OD.txdate
        AND (CASE WHEN VT_DATE <= kh.todate THEN VT_DATE ELSE kh.todate END) >= OD.txdate
        AND kh.deltd <> 'Y'
        AND OD.txdate < nvl(kh.clstxdate ,'01-Jan-2222')
        AND cf1.custid = af.custid AND af.custid = kh.afacctno
        AND cf2.custid = mg.custid
        and allcode.cdtype = 'RE' and allcode.cdname = 'REROLE' and allcode.cdval = retype.rerole
        AND substr(kh.reacctno, 11,4) = retype.actype
        AND retype.rerole LIKE V_STRREROLE
        and VF_DATE <= kh.todate
        AND VT_DATE >= kh.frdate
        AND cf2.custid LIKE V_STRCUSTODYCD*/
----       AND (mg.brid LIKE V_STRBRID OR instr(V_STRBRID,mg.brid)<> 0)
) MAIN
LEFT JOIN
(
    SELECT ACCTNO, SUM(NVL(DIRECTACR,0)) GT_GD, SUM(NVL(DISDIRECTACR,0)) GTGD_THUCHIEN,
        sum(nvl(directfeeacr,0)) GT_PHI, SUM(NVL(COMMISION,0)) THUONG_HH
    FROM RECOMMISION, retype WHERE reactype = retype.actype
        AND RECOMMISION.commdate >= VF_DATE AND RECOMMISION.commdate <= VT_DATE
    GROUP BY ACCTNO
) COM
ON MAIN.SO_TK_MG = COM.ACCTNO
LEFT JOIN
(
   /* SELECT (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0).fullname ten_truong_nhom, tn.fullname ten_nhom, nhom.reacctno, tn.autoid
    FROM regrplnk nhom, regrp tn, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) ---, remast re, RECOMMISION reco
    WHERE tn.autoid = nhom.refrecflnkid AND nhom.status = 'A'
        AND tn.custid = (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0).custid
---        AND reco.commdate >= VF_DATE AND reco.commdate <= VT_DATE
---        and tn.autoid like V_GROUPID*/
    SELECT cfmast.fullname ten_truong_nhom, tn.fullname ten_nhom, nhom.reacctno, tn.autoid,
        re.recommision+nvl(reco.THUONG_HH,0) thuong_nhom
    FROM regrplnk nhom, regrp tn,  cfmast, remast re,
        (select acctno, SUM(NVL(COMMISION,0)) THUONG_HH
        from RECOMMISION
        where commdate >= VF_DATE AND commdate <= VT_DATE
        group by acctno
        ) reco
    WHERE tn.autoid = nhom.refrecflnkid AND nhom.status = 'A'
        AND tn.custid = cfmast.custid ---AND TN.AUTOID = '35'
        and tn.custid = re.custid and tn.actype = re.actype
        and re.acctno = reco.acctno(+)
---        and tn.autoid like V_GROUPID
) reg
ON MAIN.SO_TK_MG = reg.reacctno
GROUP BY main.so_tk_kh, main.custid, main.so_tk_MG,
    main.ten_kh, main.ten_mg, main.rerole,
    main.cust_kh, main.custid_mg, main.retype, main.BIEU_HH, reg.ten_truong_nhom, reg.ten_nhom, reg.reacctno, reg.AUTOID
)
WHERE autoid LIKE V_GROUPID
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
