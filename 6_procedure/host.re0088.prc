SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0088" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2,
   REROLE         IN       VARCHAR2
 )
IS
--bao cao gia tri giao dich
--created by Chaunh at 11/01/2012
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID          VARCHAR2 (40);    -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);

    VF_DATE DATE;
    VT_DATE DATE;
    V_CUSTID varchar2(10);
    V_REROLE varchar2(4);
    V_REERNAME varchar2(50);
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

   ------------------------
   IF (REROLE <> 'ALL')
   THEN
    V_REROLE := REROLE;
   ELSE
    V_REROLE := '%';
   END IF;
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
   ------------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');
OPEN PV_REFCURSOR FOR
SELECT txdate, txnum, so_tk_kh , custid, so_tk_MG, frdate, todate, ten_kh, cust_kh, custid_mg, --ten_mg,
       nvl(ten_truong_nhom,'not join group yet') ten_truong_nhom, afstatus, rerole, sum(nvl(EXECAMT,0)) EXECAMT,
       retype||' _ '||vai_tro as retype, activedate,
       case when V_REROLE ='%' then V_REROLE else vai_tro end  pa_role, V_REERNAME ten_mg, ten_nhom
FROM
    (SELECT kh.txdate, kh.txnum, kh.afacctno so_tk_kh, mg.custid, kh.reacctno so_tk_MG, kh.frdate, kh.todate,
        cf1.fullname ten_kh, cf2.fullname ten_mg, retype.afstatus, mg.autoid, retype.rerole, cf1.custodycd cust_kh, mg.custid custid_mg,
        cf1.activedate activedate, retype.typename retype, od.execamt, allcode.cdcontent vai_tro
    FROM reaflnk kh,recflnk mg,
        afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1, 
         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf2, retype, allcode,
        (SELECT afacctno, txdate, execamt EXECAMT FROM odmast WHERE deltd <> 'Y' UNION ALL SELECT afacctno, txdate, execamt EXECAMT FROM odmasthist WHERE deltd <> 'Y') OD
    WHERE kh.refrecflnkid = mg.autoid
        AND OD.afacctno = af.acctno
        AND (CASE WHEN VF_DATE >= kh.frdate THEN VF_DATE ELSE kh.frdate end) <= OD.txdate
        AND (CASE WHEN VT_DATE <= kh.todate THEN VT_DATE ELSE kh.todate END) >= OD.txdate
        AND kh.deltd <> 'Y' --AND kh.status = 'A'
        AND OD.txdate < nvl(kh.clstxdate ,'01-Jan-2222')
        AND cf1.custid = af.custid AND af.custid = kh.afacctno
        AND cf2.custid = mg.custid
        and allcode.cdtype = 'RE' and allcode.cdname = 'REROLE' and allcode.cdval = retype.rerole
        AND substr(kh.reacctno, 11,4) = retype.actype
        AND retype.rerole LIKE V_REROLE
        and VF_DATE <= kh.todate
        AND VT_DATE >= kh.frdate
        AND cf2.custid LIKE V_CUSTID
        AND (mg.brid LIKE V_STRBRID OR instr(V_STRBRID,mg.brid)<> 0)) a
    LEFT JOIN --truong nhom
    (SELECT cfmast.fullname ten_truong_nhom, tn.fullname ten_nhom, nhom.reacctno 
     FROM regrplnk nhom, regrp tn, cfmast
    WHERE tn.autoid = nhom.refrecflnkid AND nhom.status = 'A'
        AND tn.custid = cfmast.custid) b
    ON a.so_tk_mg = b.reacctno
GROUP BY txdate, txnum, so_tk_kh , custid, so_tk_MG, frdate, todate, ten_kh, cust_kh, custid_mg, --ten_mg,
       ten_truong_nhom, afstatus, rerole,vai_tro, retype, activedate,
       V_REROLE , V_REERNAME , ten_nhom
   ORDER BY retype,cust_kh,so_tk_kh
;

EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
 
 
 
/
