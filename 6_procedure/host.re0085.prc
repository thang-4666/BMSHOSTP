SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0085" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2
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
        V_CUSTID := CUSTID;
   ELSE
    V_CUSTID := '%';
   END IF;
    VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR FOR
SELECT A.ngay_huy, a.ngay_dat, al.cdcontent exectype, a.symbol, a.matchqtty, a.matchprice, a.afacctno,
       a.vai_tro,a.ten_mg, a.TK_MG, a.isdisposal , b.ten_lmg, b.tk_lmg, b.ten_nhom, V_CUSTID custid
FROM
(
SELECT od.txdate ngay_huy,odmast.txdate ngay_dat, odmast.exectype, sb.symbol, iod.matchqtty,
iod.matchprice,odmast.afacctno,
MG.TEN_MG, MG.TK_MG, MG.reacctno ,odmast.isdisposal, MG.vai_tro
  FROM
(SELECT * FROM odtran
UNION ALL
SELECT * FROM odtrana) od, apptx, odmast, sbsecurities sb,
(
SELECT * FROM iod UNION ALL SELECT * FROM iodhist
) iod,
(
SELECT reaflnk.afacctno, cfmast.fullname TEN_MG, reaflnk.reacctno TK_MG,
reaflnk.frdate, nvl(reaflnk.clstxdate -1,reaflnk.todate) todate, reaflnk.reacctno, al.cdcontent vai_tro
FROM reaflnk,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cfmast, retype, allcode al, recflnk
WHERE substr(reaflnk.reacctno,1,10) = cfmast.custid
AND retype.actype = substr(reaflnk.reacctno,11,4)
AND al.cdtype = 'RE' AND al.cdname = 'REROLE' AND retype.rerole = al.cdval
AND cfmast.custid LIKE V_CUSTID
AND cfmast.custid = recflnk.custid
AND (recflnk.brid LIKE V_STRBRID OR instr(V_STRBRID,recflnk.brid)<> 0)
) MG
WHERE od.tltxcd = '8846' --AND od.acctno = '8000151012000141'
AND iod.orgorderid = odmast.orderid
AND apptx.field = 'REMAINQTTY'
AND od.txcd = apptx.txcd AND apptx.apptype = 'OD'
AND od.acctno = odmast.orderid
AND odmast.codeid = sb.codeid
AND od.txdate > odmast.txdate --dieu kien T1
AND odmast.afacctno = MG.afacctno
AND odmast.txdate >= MG.frdate
AND odmast.txdate <= MG.todate
AND odmast.txdate <= VT_DATE
AND odmast.txdate >= VF_DATE
) A,
(
SELECT cf_LMG.custodycd TK_LMG, Cf_LMG.fullname TEN_LMG, regrplnk.reacctno, regrp.fullname TEN_NHOM,
regrplnk.frdate, nvl(regrplnk.clstxdate -1, regrplnk.todate) todate
FROM regrplnk,regrp, cfmast cf_MG, cfmast cf_LMG
WHERE cf_MG.custid = regrplnk.custid
AND cf_LMG.custid = regrp.custid
AND regrplnk.refrecflnkid = regrp.autoid
) B, allcode al
WHERE A.reacctno = B.reacctno (+)
AND a.ngay_dat >= B.frdate (+)
AND al.cdname = 'EXECTYPE' AND al.cdtype = 'OD' AND al.cdval = a.exectype
AND a.ngay_dat <= B.todate (+)


;


EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
