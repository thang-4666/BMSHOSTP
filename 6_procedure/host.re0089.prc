SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0089" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SEARCHDATE         IN       VARCHAR2,
   CUSTODYCD         IN       VARCHAR2,
   REROLE         IN       VARCHAR2/*,
   RECUSTODYCD    IN       VARCHAR2*/
 )
IS

--bao cao Danh sach tai khoan do moi gioi quan ly
--created by Chaunh at 10/01/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);

    V_SEARCHDATE date;
    V_CUSTODYCD varchar2(10);
    V_REROLE varchar2(4);
    V_REERNAME varchar2(50);
 --   V_RECUSTODYCD  VARCHAR2(50);
BEGIN

/*   V_STROPTION := upper(OPT);
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
*/
  V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
   ------------------------
   IF (REROLE <> 'ALL')
   THEN
    V_REROLE := REROLE;
   ELSE
    V_REROLE := '%';
   END IF;
   -----------------------
   V_CUSTODYCD := CUSTODYCD;
   --V_REERNAME := 'ALL';
   IF (CUSTODYCD <> 'ALL')
   THEN
    BEGIN
        V_CUSTODYCD := CUSTODYCD;
        SELECT cf.fullname INTO V_REERNAME FROM cfmast cf WHERE cf.custid like V_CUSTODYCD;
    END ;
   ELSE
    V_CUSTODYCD := '%%';
    V_REERNAME := 'ALL';
   END IF;

   /* IF (RECUSTODYCD <> 'ALL')
   THEN
    V_RECUSTODYCD := RECUSTODYCD;
   ELSE
    V_RECUSTODYCD := '%';
   END IF;*/
   ------------------------------
   V_SEARCHDATE := to_date(SEARCHDATE, 'dd/MM/RRRR');


OPEN PV_REFCURSOR FOR

SELECT txdate, txnum, so_tk_kh , custid, so_tk_MG, frdate, todate, ten_kh, cust_kh, custid_mg,
    retyApe || ' - ' || typename || '('|| vai_tro || ')'  retype,
    nvl(ten_truong_nhom,' ') ten_truong_nhom, afstatus, rerole, V_SEARCHDATE searchdate, pa_role,
    V_REERNAME ten_mg, ten_nhom, autoid,CFTYPE
FROM
    (SELECT kh.frdate txdate, kh.txnum, kh.afacctno so_tk_kh, cf1.custid, kh.reacctno so_tk_MG, --cf1.valdate frdate,
        CF1.opndate frdate, kh.todate, NVL(CFT.TYPENAME,'') CFTYPE,
        cf1.fullname ten_kh, cf2.fullname ten_mg, RETYPE.afstatus, mg.autoid, retype.rerole, allcode.cdcontent vai_tro,
        cf1.custodycd cust_kh, cf2.custid custid_mg, retype.actype retyApe,
        (CASE WHEN V_REROLE = '%' THEN '%' ELSE to_char(allcode.cdcontent) END) pa_role, RETYPE.typename
    FROM reaflnk kh,recflnk mg,
        (select custid, max(acctno) acctno from afmast group by custid) af,CFTYPE CFT,
        (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf1,
         (SELECT * FROM CFMAST ) cf2, retype, allcode
    WHERE kh.refrecflnkid = mg.autoid
        AND allcode.cdtype = 'RE' AND allcode.cdname = 'REROLE' AND allcode.cdval = retype.rerole
        AND kh.deltd <> 'Y' AND CF1.ACTYPE=CFT.ACTYPE
        AND cf1.custid = af.custid AND cf1.custid = kh.afacctno and kh.status = 'A'
        AND cf2.custid = mg.custid
        AND V_SEARCHDATE <= nvl(kh.clstxdate - 1,kh.todate)
        AND V_SEARCHDATE >= kh.frdate
        AND substr(kh.reacctno, 11,4) = retype.actype
        AND (mg.brid LIKE V_STRBRID OR instr(V_STRBRID,mg.brid)<> 0)) a
    LEFT JOIN --truong nhom
    (SELECT cfmast.fullname ten_truong_nhom, tn.fullname ten_nhom, nhom.reacctno
    FROM regrplnk nhom, regrp tn,(SELECT * FROM CFMAST ) cfmast
    WHERE tn.autoid = nhom.refrecflnkid AND nhom.status = 'A'
        AND tn.custid = cfmast.custid
        --AND (substr(cfmast.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cfmast.custid,1,4))<> 0)
        ) b
    ON a.so_tk_mg = b.reacctno
WHERE custid_mg LIKE V_CUSTODYCD
--AND custid_mg LIKE V_RECUSTODYCD
AND rerole LIKE V_REROLE
and V_SEARCHDATE <= todate    -- todate, frdate da duoc de dinh dang kieu date
AND V_SEARCHDATE >= frdate
ORDER BY afstatus,a.ten_kh
    ;

EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
