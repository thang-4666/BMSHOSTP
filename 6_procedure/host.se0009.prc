SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0009 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   CIACCTNO       IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   P_MAKERID      IN        VARCHAR2,
   P_CHECKERID    IN        VARCHAR2,
   P_TLTXCD       IN        VARCHAR2,
   I_BRIDGD       IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO SO DU PHONG TOA CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   11-JUL-10  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRCIACCTNO      VARCHAR (20);
   V_STRSYMBOL        VARCHAR (20);
   V_STRCUSTODYCD     VARCHAR2 (20);
   V_FDATE           DATE;
   V_TDATE           DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_MAKERID              VARCHAR2(4);
   V_CHECKERID            VARCHAR2(4);
   V_TLTXCD               VARCHAR2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   -- GET REPORT'S PARAMETERS

   IF(upper(CUSTODYCD) = 'ALL' or CUSTODYCD is null) THEN
     V_STRCUSTODYCD := '%';
   ELSE
     V_STRCUSTODYCD := CUSTODYCD;
   END IF;

   IF(upper(CIACCTNO) = 'ALL' or CIACCTNO is null) THEN
     V_STRCIACCTNO := '%';
   ELSE
     V_STRCIACCTNO := CIACCTNO;
   END IF;

   IF(SYMBOL  <> 'ALL')
   THEN
      V_STRSYMBOL := replace(SYMBOL,' ','_');
   ELSE
      V_STRSYMBOL := '%%';
   END IF;

   V_FDATE := to_date(F_DATE,'DD/MM/YYYY');
   V_TDATE := to_date(T_DATE,'DD/MM/YYYY');

   IF P_CHECKERID <> 'ALL' THEN V_CHECKERID := P_CHECKERID;
   ELSE V_CHECKERID := '%%';
   END IF;

   IF P_MAKERID <> 'ALL' THEN V_MAKERID := P_MAKERID;
   ELSE V_MAKERID := '%%';
   END IF;

   IF P_TLTXCD <> 'ALL' THEN V_TLTXCD := P_TLTXCD;
   ELSE V_TLTXCD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  'To?c?ty';
   END IF;

--- GET REPORT' DATA
OPEN PV_REFCURSOR
    FOR
    /*
---giao dich 2200 tren chung khoan giao dich
SELECT TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) SYMBOL,
    sum(TR.NAMT) namt,
    avg(case when sb.refcodeid is null then '1' else '7' end) sectype
FROM VW_SETRAN_GEN TR, CFMAST CF, sbsecurities sb, sbsecurities sb1
WHERE TR.TLTXCD = '2200'
    AND TR.FIELD = 'TRADE'
    and tr.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    AND TR.DELTD <> 'Y' AND TR.CUSTODYCD = CF.CUSTODYCD
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND TR.AFACCTNO LIKE V_STRCIACCTNO
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
    and (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
GROUP BY TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)
union all
---giao dich 2200 tren chung khoan phong toa
SELECT TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) SYMBOL,
    sum(TR.NAMT) namt,
    avg(case when sb.refcodeid is null then '2' else '8' end) sectype
FROM VW_SETRAN_GEN TR, CFMAST CF, sbsecurities sb, sbsecurities sb1
WHERE TR.TLTXCD = '2200'
    AND TR.FIELD = 'BLOCKED'
    and tr.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    AND TR.DELTD <> 'Y' AND TR.CUSTODYCD = CF.CUSTODYCD
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND TR.AFACCTNO LIKE V_STRCIACCTNO
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
        and (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
GROUP BY TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)
union all
SELECT DISTINCT TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) SYMBOL,
    0 namt,
    null sectype
FROM VW_SETRAN_GEN TR, CFMAST CF, sbsecurities sb, sbsecurities sb1,
    v_tllog
WHERE TR.TLTXCD IN ('2294','2292','2293','2201')
    AND TR.DELTD <> 'Y' AND TR.CUSTODYCD = CF.CUSTODYCD
    and tr.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND TR.AFACCTNO LIKE V_STRCIACCTNO
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
        and (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
*/
---giao dich 2200 tren chung khoan phong toa
select * from
(
SELECT TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,tr.field,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) SYMBOL,
    sum(TR.NAMT) namt,
    (case when sb.refcodeid is null then
        (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '1,2'
              when wd.withdraw = 0 then '2' else '1' end) else
         (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '7,8'
               when wd.withdraw = 0 then '8' else '7' end) end)  sectype,
    wd.txdate opdate, AFT.TYPENAME, NVL(MK.TLNAME,' ') MAKER, NVL(CK.TLNAME, ' ') CHECKER
FROM VW_SETRAN_GEN TR, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, sbsecurities sb, sbsecurities sb1,
    sewithdrawdtl wd, AFMAST AF, AFTYPE AFT, tlprofiles MK, tlprofiles CK
WHERE TR.TLTXCD = '2200'
    AND TR.FIELD in ('TRADE','BLOCKED')
    and tr.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    and tr.txnum = wd.txnum and tr.txdate = wd.txdate
    AND AF.ACCTNO = TR.AFACCTNO AND AF.ACTYPE = AFT.ACTYPE AND TR.TLID = MK.TLID(+) AND TR.OFFID = CK.TLID(+)
    AND TR.DELTD <> 'Y' AND TR.CUSTODYCD = CF.CUSTODYCD
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND TR.AFACCTNO LIKE V_STRCIACCTNO
    AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
    AND TR.TLID LIKE V_MAKERID AND TR.OFFID LIKE V_CHECKERID AND TR.TLTXCD LIKE V_TLTXCD
    and (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
GROUP BY TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,tr.field,AFT.TYPENAME, NVL(MK.TLNAME,' ') , NVL(CK.TLNAME, ' ') ,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) ,
    (case when sb.refcodeid is null then
        (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '1,2'
              when wd.withdraw = 0 then '2' else '1' end) else
         (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '7,8'
               when wd.withdraw = 0 then '8' else '7' end) end), wd.txdate
union all
SELECT DISTINCT TR.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
    (CASE WHEN TR.txcd='0042' THEN 'TRADE' ELSE 'BLOCK' END) field,
    (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end) SYMBOL,
    TR.namt namt,
    (case when sb.refcodeid is null then
        (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '1,2'
              when wd.withdraw = 0 then '2' else '1' end) else
         (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '7,8'
               when wd.withdraw = 0 then '8' else '7' end) end)  sectype,
    wd.txdate opdate, AFT.TYPENAME, NVL(MK.TLNAME,' ') MAKER, NVL(CK.TLNAME, ' ') CHECKER
FROM vw_setran_gen TR, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, sbsecurities sb, sbsecurities sb1,
    (
    select txnum, txdate, fldcd, cvalue from tllogfldall
    where fldcd = '07'
    union all
    select txnum, txdate, fldcd, cvalue from tllogfld
    where fldcd = '07'
    )fld , sewithdrawdtl wd,  AFMAST AF, AFTYPE AFT, tlprofiles MK, tlprofiles CK
WHERE TR.TLTXCD IN ('2293','2201')
    and FLD.txnum = tr.txnum and FLD.txdate = tr.txdate
    and FLD.cvalue = wd.txdatetxnum
    AND TR.txcd IN ('0042','0088')
    AND TR.DELTD <> 'Y' AND TR.CUSTODYCD = CF.CUSTODYCD
    and tr.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    AND AF.ACCTNO = TR.AFACCTNO AND AF.ACTYPE = AFT.ACTYPE AND TR.TLID = MK.TLID(+) AND TR.OFFID = CK.TLID(+)
    AND substr(CF.BRID,1,4) LIKE V_I_BRIDGD
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND TR.AFACCTNO LIKE V_STRCIACCTNO
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
    AND TR.TLID LIKE V_MAKERID AND TR.OFFID LIKE V_CHECKERID AND TR.TLTXCD LIKE V_TLTXCD
    and (case when sb.refcodeid is null then TR.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
union all
SELECT DISTINCT af.acctno AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TR.TXNUM, TR.TXDATE, TR.TLTXCD,
     (case when fld1.fldcd='10' then 'TRADE' ELSE 'BLOCKED' END) FIELD,
    (case when sb.refcodeid is null then sb.symbol else sb1.symbol end) SYMBOL,fld1.nvalue namt,
    (case when sb.refcodeid is null then
        (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '1,2'
              when wd.withdraw = 0 then '2' else '1' end) else
         (case when wd.withdraw <> 0 and wd.blockwithdraw <> 0 then '7,8'
               when wd.withdraw = 0 then '8' else '7' end) end)  sectype,
    wd.txdate opdate, AFT.TYPENAME, NVL(MK.TLNAME,' ') MAKER, NVL(CK.TLNAME, ' ') CHECKER
FROM vw_tllog_all TR,(
    select txnum, txdate, fldcd, cvalue from tllogfldall
    where fldcd = '07'
    union all
    select txnum, txdate, fldcd, cvalue from tllogfld
    where fldcd = '07'
    )fld ,
    (
    select txnum, txdate, fldcd, nvalue from tllogfldall
    where fldcd IN ( '10','14')
    union all
    select txnum, txdate, fldcd, nvalue from tllogfld
    where fldcd IN ( '10','14')
    )fld1 ,
     (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, sbsecurities sb, sbsecurities sb1,
    sewithdrawdtl wd, afmast af, AFTYPE AFT, tlprofiles MK, tlprofiles CK
WHERE TR.TLTXCD IN ( '2294','2292')
    and tr.txnum=fld.TXNUM
    and tr.txdate=fld.TXDATE
    and tr.txnum=fld1.TXNUM
    and tr.txdate=fld1.TXDATE
    and fld.cvalue=wd.txdatetxnum
    AND TR.TXSTATUS='1'
    AND TR.DELTD <> 'Y' AND wd.afacctno = af.acctno
    and af.custid = CF.custid
   -- AND AF.ACTYPE NOT IN ('0000')
    and wd.codeid = sb.codeid
    and sb.refcodeid = sb1.codeid(+)
    AND FLD1.NVALUE >0
    AND AF.ACTYPE = AFT.ACTYPE AND TR.TLID = MK.TLID(+) AND TR.OFFID = CK.TLID(+)
    AND substr(CF.BRID,1,4) LIKE V_I_BRIDGD
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND af.ACCTNO LIKE V_STRCIACCTNO
    AND TR.TXDATE >= V_FDATE
    AND TR.TXDATE <= V_TDATE
    AND TR.TLID LIKE V_MAKERID AND TR.OFFID LIKE V_CHECKERID AND TR.TLTXCD LIKE V_TLTXCD
    and (case when sb.refcodeid is null then sb.SYMBOL else sb1.symbol end)  like  V_STRSYMBOL
)
order by CUSTODYCD, TXDATE, TXNUM, TLTXCD
;


 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
