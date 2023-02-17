SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0031" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
    TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PLSENT         in       varchar2
)
IS

-- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE
-- PERSON --------------DATE---------------------COMMENTS
-- QUYET.KIEU           11/02/2011               CREATE NEW
-- DIENNT               09/01/2012               EDIT
-- ---------   ------  -------------------------------------------
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_TYPE  VARCHAR2(10);

   V_CURRDATE date;
   v_flag number(2,0);

BEGIN
-- GET REPORT'S PARAMETERS


    V_CUSTODYCD := upper( PV_CUSTODYCD);
    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
     from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

/*
   IF  (LOWER(PV_TYPE) = 'tat toan')

   THEN
         V_TYPE := '2247' ;
   ELSE
         V_TYPE := '8815' ;
   END IF;
*/

   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
         V_STRAFACCTNO := '%';
   END IF;

select count (1) into v_flag from
(
select DISTINCT cf.custodycd , tl.type
  FROM   (
            SELECT   tl.txdate,tl.txnum,
                 max(SUBSTR (msgacct, 0, 10)) acctno,
                 max(nvl(sb.refcodeid,sb.codeid))codeid,
                 max(se.namt) msgamt, max (case when sb.refcodeid is null then '(1)' else '(7)' end) type,
                 max(decode(fld.fldcd,'11',fld.nvalue,null)) MENH_GIA,
                 max(decode(fld.fldcd,'27',cvalue,null)) MA_TVLK_NHAN,
                 max(decode(fld.fldcd,'28',cvalue,null)) SO_TKLK_NHAN,
                 max(decode(fld.fldcd,'29',cvalue,null)) TEN_NGUOI_NHAN
               FROM   vw_tllog_all tl,sbsecurities sb, vw_setran_all se,
                       vw_tllogfld_all fld, trfdtoclose tr
                   WHERE   tl.tltxcd = '2247'  AND tl.DELTD = 'N'
                   and se.txnum=tl.txnum and se.txdate=tl.txdate
                   and fld.txnum=tl.txnum and fld.txdate=tl.txdate
                  AND tr.txnum = tl.txnum AND tr.txdate = tl.txdate
                   AND tr.deltd <> 'Y'
                   and se.txcd='0040'
                   and se.namt<>0
                   and substr(msgacct, 11, 6)=sb.codeid
                   AND tl.txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                   AND tl.txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                   group by tl.txnum,tl.txdate
           UNION all
           SELECT   tl.txdate,tl.txnum,
                 max(SUBSTR (msgacct, 0, 10)) acctno,
                 max(nvl(sb.refcodeid,sb.codeid))codeid,
                 max(se.namt) msgamt, max (case when sb.refcodeid is null then '(2)' else '(8)' end) type,
                 max(decode(fld.fldcd,'11',fld.nvalue,null)) MENH_GIA,
                 max(decode(fld.fldcd,'27',cvalue,null)) MA_TVLK_NHAN,
                 max(decode(fld.fldcd,'28',cvalue,null)) SO_TKLK_NHAN,
                 max(decode(fld.fldcd,'29',cvalue,null)) TEN_NGUOI_NHAN
                FROM   vw_tllog_all tl,sbsecurities sb, vw_setran_all se,
                       vw_tllogfld_all fld, trfdtoclose tr
                   WHERE   tl.tltxcd = '2247'  AND tl.DELTD = 'N'
                   and se.txnum=tl.txnum and se.txdate=tl.txdate
                   and fld.txnum=tl.txnum and fld.txdate=tl.txdate
                  AND tr.txnum = tl.txnum AND tr.txdate = tl.txdate
                   AND tr.deltd <> 'Y'
                   and se.txcd='0044'
                   and se.namt<>0
                   and substr(msgacct, 11, 6)=sb.codeid
                   AND tl.txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                   AND tl.txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                   group by tl.txnum,tl.txdate
           ) tl,
         afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, sbsecurities sb, securities_info Se, deposit_member mb
 WHERE  tl.acctno = af.acctno
         AND af.custid = cf.custid
         --AND AF.ACTYPE NOT IN ('0000')
         and se.codeid = sb.codeid
         AND tl.codeid = sb.codeid
       --  AND sb.tradeplace IN ('001', '002', '005')
         AND Cf.CUSTODYCD = V_CUSTODYCD
         AND tl.acctno LIKE V_STRAFACCTNO
         AND tl.MA_TVLK_NHAN = mb.depositid(+)
    );



-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT  v_flag flag, to_char(V_CURRDATE) currdate, PLSENT sendto,
      (case when sb.tradeplace='002' then 'HNX'
          when sb.tradeplace='001' then 'HOSE'
          when sb.tradeplace='005' then 'UPCOM'
          when sb.tradeplace='007' then 'TR?I PHI? CHUY? BI?T'
          when sb.tradeplace='008' then 'T? PHI?U'
          when sb.tradeplace='009' then '?CNY'
          else '' end)  san,
    cf.fullname fullname, cf.idcode idcode,
    cf.iddate iddate, cf.custodycd custodycd,
         nvl(sb.symbol,'') codeid,
         nvl(tl.MENH_GIA ,'') MENH_GIA,
         nvl(tl.msgamt,'') sl_lole,
         nvl(tl.MA_TVLK_NHAN,'') MA_TVLK_NHAN,
         nvl(tl.SO_TKLK_NHAN,'') SO_TKLK_NHAN,
         nvl(tl.TEN_NGUOI_NHAN,'') TEN_NGUOI_NHAN,

        ('012' || (case when SUBSTR(tl.type, 2,1) IN ('8','7') then '72' else
            (case when SUBSTR(tl.type, 2,1) = '1' THEN '12' ELSE '22' END) end) || '.' || tl.MA_TVLK_NHAN) TK_NO,
        ('012' || (case when SUBSTR(tl.type, 2,1) IN ('8','7') then '72' else
            (case when SUBSTR(tl.type, 2,1) = '1' THEN '12' ELSE '22' END) end)
            || '.009') TK_CO,
         tl.type, nvl(mb.fullname,'') TEN_TVLK,
         cf.fullname NGUOI_CHUYEN_KHOAN,
            V_CUSTODYCD SO_TAI_KHOAN
  FROM   (
            SELECT   tl.txdate,tl.txnum,
                 max(SUBSTR (msgacct, 0, 10)) acctno,
                 max(nvl(sb.refcodeid,sb.codeid))codeid,
                 max(se.namt) msgamt, max (case when sb.refcodeid is null then '(1)' else '(7)' end) type,
                 max(decode(fld.fldcd,'11',fld.nvalue,null)) MENH_GIA,
                 max(decode(fld.fldcd,'27',cvalue,null)) MA_TVLK_NHAN,
                 max(decode(fld.fldcd,'28',cvalue,null)) SO_TKLK_NHAN,
                 max(decode(fld.fldcd,'29',cvalue,null)) TEN_NGUOI_NHAN
               FROM   vw_tllog_all tl,sbsecurities sb, vw_setran_all se,
                       vw_tllogfld_all fld, trfdtoclose tr
                   WHERE   tl.tltxcd = '2247'  AND tl.DELTD = 'N'
                   and se.txnum=tl.txnum and se.txdate=tl.txdate
                   and fld.txnum=tl.txnum and fld.txdate=tl.txdate
                   AND tr.txnum = tl.txnum AND tr.txdate = tl.txdate
                   AND tr.deltd <> 'Y'
                   and se.txcd IN ('0040','0015')
                   and se.namt<>0
                   and substr(msgacct, 11, 6)=sb.codeid
                   AND tl.txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                   AND tl.txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                   group by tl.txnum,tl.txdate
           UNION all
           SELECT   tl.txdate,tl.txnum,
                 max(SUBSTR (msgacct, 0, 10)) acctno,
                 max(nvl(sb.refcodeid,sb.codeid))codeid,
                 max(se.namt) msgamt, max (case when sb.refcodeid is null then '(2)' else '(8)' end) type,
                 max(decode(fld.fldcd,'11',fld.nvalue,null)) MENH_GIA,
                 max(decode(fld.fldcd,'27',cvalue,null)) MA_TVLK_NHAN,
                 max(decode(fld.fldcd,'28',cvalue,null)) SO_TKLK_NHAN,
                 max(decode(fld.fldcd,'29',cvalue,null)) TEN_NGUOI_NHAN
                FROM   vw_tllog_all tl,sbsecurities sb, vw_setran_all se,
                       vw_tllogfld_all fld, trfdtoclose tr
                   WHERE   tl.tltxcd = '2247'  AND tl.DELTD = 'N'
                   and se.txnum=tl.txnum and se.txdate=tl.txdate
                   and fld.txnum=tl.txnum and fld.txdate=tl.txdate
                   AND tr.txnum = tl.txnum AND tr.txdate = tl.txdate
                   AND tr.deltd <> 'Y'
                   and se.txcd='0044'
                   and se.namt<>0
                   and substr(msgacct, 11, 6)=sb.codeid
                   AND tl.txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                   AND tl.txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                   group by tl.txnum,tl.txdate
           ) tl,
         afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, sbsecurities sb, securities_info Se, deposit_member mb
 WHERE  tl.acctno = af.acctno
         AND af.custid = cf.custid
         --AND AF.ACTYPE NOT IN ('0000')
         and se.codeid = sb.codeid
         AND tl.codeid = sb.codeid
        -- AND sb.tradeplace IN ('001', '002', '005')
         AND Cf.CUSTODYCD = V_CUSTODYCD
         AND tl.acctno LIKE V_STRAFACCTNO
         AND tl.MA_TVLK_NHAN = mb.depositid(+)
         ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
