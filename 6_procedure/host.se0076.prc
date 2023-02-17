SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0076" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2

 )
IS
--Tong hop phi chuyen khoan - chuyen khoan tat toan tk
--created by Chaunh at 07/05/2012

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;

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
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');



OPEN PV_REFCURSOR FOR

/*SELECT cf.fullname, cf.custodycd,
        CASE WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'F' THEN 'Ca nhan nuoc ngoai'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'F' THEN 'To chuc nuoc ngoai'
             WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'C' THEN 'Ca nhan trong nuoc'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'C' THEN 'To chuc trong nuoc'
             WHEN substr(cf.custodycd,4,1) = 'P' THEN 'Tu doanh'
        END loai_hinh,
        sum(fld.nvalue) phi
FROM vw_tllog_all tl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf , afmast af,
(select * from vw_tllogfld_all where fldcd='55' and nvalue>0 and txdate between VF_DATE and VT_DATE)fld
WHERE tl.tltxcd = '0088' AND tl.deltd <> 'Y' and tl.TXSTATUS in ('1','7')
AND substr(tl.msgacct,1,10) = af.acctno
and tl.txdate=fld.txdate and tl.txnum=fld.txnum
AND cf.custatcom = 'Y'
AND af.custid = cf.custid
AND tl.txdate between  VF_DATE and VT_DATE
GROUP BY cf.fullname, cf.custodycd,
        CASE WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'F' THEN 'Ca nhan nuoc ngoai'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'F' THEN 'To chuc nuoc ngoai'
             WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'C' THEN 'Ca nhan trong nuoc'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'C' THEN 'To chuc trong nuoc'
             WHEN substr(cf.custodycd,4,1) = 'P' THEN 'Tu doanh'
        END
;*/
SELECT cf.fullname, cf.custodycd,
        CASE WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'F' THEN 'Ca nhan nuoc ngoai'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'F' THEN 'To chuc nuoc ngoai'
             WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'C' THEN 'Ca nhan trong nuoc'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'C' THEN 'To chuc trong nuoc'
             WHEN substr(cf.custodycd,4,1) = 'P' THEN 'Tu doanh'
        END loai_hinh,
        sum(ci.namt) phi
FROM vw_citran_gen ci,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf , afmast af
WHERE ci.tltxcd = '0088' and ci.txcd='0011' and ci.trdesc is null
AND ci.deltd <> 'Y'
AND ci.acctno = af.acctno
AND cf.custatcom = 'Y'
AND af.custid = cf.custid
AND ci.txdate between  VF_DATE and VT_DATE
GROUP BY cf.fullname, cf.custodycd,
        CASE WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'F' THEN 'Ca nhan nuoc ngoai'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'F' THEN 'To chuc nuoc ngoai'
             WHEN cf.custtype = 'I' AND substr(cf.custodycd,4,1) = 'C' THEN 'Ca nhan trong nuoc'
             WHEN cf.custtype = 'B' AND substr(cf.custodycd,4,1) = 'C' THEN 'To chuc trong nuoc'
             WHEN substr(cf.custodycd,4,1) = 'P' THEN 'Tu doanh'
        END
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
