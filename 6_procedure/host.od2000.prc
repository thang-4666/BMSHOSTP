SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od2000 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_TLTXCD        IN       VARCHAR2,
   PV_SYMBOL         in       varchar2
       )
IS


-- created by Chaunh at 23/10/2012
-- ---------   ------  -------------------------------------------
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_SYMBOL varchar2(20);
   V_TLTXCD varchar2(10);
   V_FROMDATE date;
   V_TODATE date;
BEGIN
-- GET REPORT'S PARAMETERS
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


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%';
   END IF;

   IF  (PV_SYMBOL <> 'ALL')
   THEN
         V_SYMBOL := replace(PV_SYMBOL,' ','_');
   ELSE
        V_SYMBOL := '%';
   END IF;

   IF  (PV_TLTXCD <> 'ALL')
   THEN
         V_TLTXCD := PV_TLTXCD;
   ELSE
        V_TLTXCD := '%';
   END IF;


   V_FROMDATE:=to_date(F_DATE,'DD/MM/RRRR');
   V_TODATE:=to_date(T_DATE,'DD/MM/RRRR');

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
 SELECT * FROM (
 SELECT CASE WHEN tl.tltxcd = '8841' THEN od.txdate ELSE null END Ngay_phat_sinh,
       tl.busdate Ngay_chung_tu, cf.custodycd, cf.fullname, af.acctno, a1.cdcontent  loai_lenh,
       sb.symbol, od.orderqtty, od.quoteprice,  decode(od.execqtty,0,chd.qtty,od.execqtty) execqtty,
       round(decode(od.execamt,0,chd.amt,od.execamt)/ decode(od.execqtty,0,chd.qtty,od.execqtty)) gia_khop,
       t1.tlfullname nguoi_tao, t2.tlfullname nguoi_duyet,
       CASE WHEN tl.tltxcd = '8841'  THEN fld1.cvalue ELSE null END nguoi_gay_loi,
       tl.tltxcd ma_giao_dich, a2.cdcontent nguyen_nhan_loi,
       CASE WHEN tl.tltxcd = '8848' THEN a3.cdcontent ELSE null END loai_sua_loi,
       --CASE WHEN tl.tltxcd = '8848' AND fld.fldcd = '20' THEN a3.cdcontent ELSE null END loai_sua_loi,
       tl.txtime, tl.txdesc, od.orderid
FROM (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) od,
    (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, allcode a1, sbsecurities sb,
    tlprofiles t1, tlprofiles t2, vw_tllog_all tl, tlprofiles t3,
    (SELECT * FROM allcode WHERE  cdtype = 'OD' AND cdname = 'ERRREASON')  a2,
    (SELECT * from allcode WHERE cdtype = 'OD' AND cdname = 'FIXERRTYPE') a3,
    (SELECT DISTINCT STS.*  FROM stschd STS WHERE duetype in ('SS','RS')
    UNION ALL SELECT DISTINCT STS.* FROM stschdhist STS WHERE duetype in ('SS','RS')) chd,
    (SELECT txdate, txnum, cvalue, fldcd FROM vw_tllogfld_all WHERE fldcd =  '25' ) fld1,
    (SELECT txdate, txnum, cvalue, fldcd FROM vw_tllogfld_all WHERE fldcd =  '20' ) fld2
WHERE tl.tltxcd IN ('8841','8847', '8842','8846','8848', '8849')
AND od.orderid = tl.msgacct
AND od.afacctno = af.acctno AND af.custid = cf.custid
----AND AF.ACTYPE NOT IN ('0000')
AND a1.cdtype = 'OD' AND a1.cdname = 'EXECTYPE' AND a1.cdval = od.exectype
AND sb.codeid = od.codeid
AND tl.tlid = t1.tlid(+) AND tl.offid = t2.tlid(+) AND od.tlid = t3.tlid(+)
AND od.errreason = a2.cdval (+)
AND fld2.cvalue = a3.cdval (+)
AND od.orderid = chd.orgorderid (+)
AND tl.txdate = fld1.txdate(+) AND tl.txnum = fld1.txnum (+)
AND tl.txdate = fld2.txdate(+) AND tl.txnum = fld2.txnum (+)
AND cf.custodycd LIKE V_CUSTODYCD
AND af.acctno LIKE V_STRAFACCTNO
AND tl.tltxcd LIKE V_TLTXCD
AND tl.txdate BETWEEN V_FROMDATE AND V_TODATE
AND sb.symbol LIKE V_SYMBOL
AND (substr(af.acctno,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(af.acctno,1,4))<> 0)


UNION ALL

SELECT tl.txdate Ngay_phat_sinh,
       tl.busdate Ngay_chung_tu, cf.custodycd, cf.fullname, af.acctno, a1.cdcontent  loai_lenh,
       sb.symbol, od.orderqtty, od.quoteprice, od.execqtty execqtty,
       od.quoteprice gia_khop,
       t1.tlfullname nguoi_tao, t2.tlfullname nguoi_duyet,
       max(CASE WHEN fld.fldcd = '25' THEN cvalue ELSE ' ' END)  nguoi_gay_loi, tl.tltxcd ma_giao_dich,
       tl.txdesc nguyen_nhan_loi,
       max(CASE WHEN fld.fldcd = '20' THEN a3.cdcontent ELSE ' ' END) loai_sua_loi,
       tl.txtime, tl.txdesc, od.orderid
FROM (SELECT * FROM odmast WHERE errodref is NOT NULL union ALL SELECT * FROM odmasthist WHERE errodref is NOT NULL) od,
    vw_tllog_all tl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, allcode a1, sbsecurities sb, tlprofiles t1, tlprofiles t2,
    vw_tllogfld_all fld,
    (SELECT * from allcode WHERE cdtype = 'OD' AND cdname = 'FIXERRTYPE') a3
WHERE substr(od.errodref,1,10) = tl.txnum AND to_date(substr(od.errodref,11,10),'DD/MM/RRRR') = tl.txdate
AND tl.tltxcd = '8843' AND cf.custid = af.custid AND af.acctno = od.afacctno
AND a1.cdtype = 'OD' AND a1.cdname = 'EXECTYPE' AND a1.cdval = od.exectype
AND od.codeid = sb.codeid
AND tl.tlid = t1.tlid(+) AND tl.offid = t2.tlid(+)
AND fld.cvalue = a3.cdval (+)
AND fld.txdate = tl.txdate AND fld.txnum = tl.txnum AND fld.fldcd IN ('20','25')
AND cf.custodycd LIKE V_CUSTODYCD
AND af.acctno LIKE V_STRAFACCTNO
----AND AF.ACTYPE NOT IN ('0000')
AND tl.tltxcd LIKE V_TLTXCD
AND tl.txdate BETWEEN V_FROMDATE AND V_TODATE
AND sb.symbol LIKE V_SYMBOL
GROUP BY tl.txdate ,
       tl.busdate , cf.custodycd, cf.fullname, af.acctno, a1.cdcontent ,
       sb.symbol, od.orderqtty, od.quoteprice, od.execqtty ,
       t1.tlfullname , t2.tlfullname , tl.tltxcd ,    tl.txdesc ,
       tl.txtime, tl.txdesc, od.orderid
)

ORDER BY orderid, Ngay_phat_sinh, ngay_chung_tu, txtime

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
