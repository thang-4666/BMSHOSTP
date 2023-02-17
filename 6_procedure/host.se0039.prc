SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0039 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PLSENT         IN       VARCHAR2,
   HDNUM          IN       VARCHAR2
)
IS

-- RP NAME : BANG KE CHUNG KHOAN CAM CO 21A/LK
-- PERSON : QUYET.KIEU
-- DATE :  05/05/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------
   V_SYMBOL  VARCHAR2 (20);
   V_CUSTODYCD VARCHAR2 (15);
   V_TRADEPLACE VARCHAR2 (15);
   V_STRPLSENT VARCHAR2 (100);
   V_STRHDNUM   VARCHAR2(100);

BEGIN
-- GET REPORT'S PARAMETERS


   IF  (TRADEPLACE <> 'ALL')
   THEN
         V_TRADEPLACE := TRADEPLACE;
   ELSE
        V_TRADEPLACE := '%';
   END IF;


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_SYMBOL <> 'ALL')
   THEN
         V_SYMBOL := PV_SYMBOL;
   ELSE
      V_SYMBOL := '%';
   END IF;

   V_STRPLSENT := PLSENT;

      IF  (HDNUM <> 'ALL')
   THEN
         V_STRHDNUM := HDNUM;
   ELSE
      V_STRHDNUM := '%';
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
Select V_STRPLSENT PLSENT,
        (case
           when sb.tradeplace='002' then '1. HNX'
          when sb.tradeplace='001' then '2. HOSE'
          when sb.tradeplace='005' then '3. UPCOM'
          when sb.tradeplace='007' then '4. TR�I PHI� CHUY� BI?T'
          when sb.tradeplace='008' then '6. T� PHI?U'
          when sb.tradeplace='009' then '7. �CNY'
             else '' end) san,
          Cf.fullname ,
          cf.custodycd So_TK_luuKY,
          cf.IDcode IDcode,
          Cf.iddate Ngay_cap,
          se.acctno Afacctno ,
          se.txdate Ngay_cam_co,
            NVL(mor.CVALUE,'') Ben_nhan_Camco ,
         NVL(SE.NGAY,'') Ngay_hop_dong_camco,
          SE.CVALUE So_hop_dong_camco,
          iss.fullname To_chuc_phat_hanh,
         (CASE WHEN instr(sb.symbol1,'_WFT') <> 0 then '7' else '1' end) Codeid ,
         sb.symbol Ma_CK,
         (nvl(sb.Parvalue,0)) Menh_Gia ,
         (nvl(se.msgamt,0)) msgamt

 from (
/*SELECT   se.txdate, se.txnum,FLD.CVALUE,
         SUBSTR (se.acctno, 0, 10) acctno,
         SUBSTR (se.acctno, 11, 6) codeid,
        se. namt msgamt
  FROM   setran se, vw_tllogfld_all fld
 WHERE       se.tltxcd = '2232'
         AND se.txcd = '0087'
         and se.txnum=fld.TXNUM
         AND SE.TXDATE=FLD.TXDATE
         AND FLD.FLDCD='13'
         and UPPER(NVL(fld.CVALUE,'0000')) LIKE V_STRHDNUM
         AND se.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND se.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
UNION ALL
SELECT   se.txdate, se.txnum,FLD.CVALUE,
         SUBSTR (se.acctno, 0, 10) acctno,
         SUBSTR (se.acctno, 11, 6) codeid,
        se. namt msgamt
  FROM   setrana se, vw_tllogfld_all fld
 WHERE       se.tltxcd = '2232'
         AND se.txcd = '0087'
         and se.txnum=fld.TXNUM
         AND SE.TXDATE=FLD.TXDATE
         AND FLD.FLDCD='13'
         and UPPER(NVL(fld.CVALUE,'0000')) LIKE V_STRHDNUM
         AND se.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND se.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')*/
        SELECT   se.txdate, se.txnum,FLD.CVALUE,TO_char(FLD1.CVALUE) NGAY,
         SUBSTR (se.MSGACCT, 0, 10) acctno,
         SUBSTR (se.MSGACCT, 11, 6) codeid,
        se.msgamt
  FROM   VW_TLLOG_ALL se, vw_tllogfld_all fld, vw_tllogfld_all FLD1, SEMORTAGE SE1
 WHERE       se.tltxcd = '2232'
         and se.txnum=fld.TXNUM
         AND SE.TXDATE=FLD.TXDATE
         and se.txnum=fld1.TXNUM
         AND SE.TXDATE=FLD1.TXDATE
         AND FLD.FLDCD='13'
         AND SE.TXDATE=SE1.TXDATE(+)
         AND SE.TXNUM=SE1.TXNUM(+)
         AND SE1.DELTD<>'Y'
         AND FLD1.FLDCD='12'
         AND SE.DELTD<>'Y' AND SE.TXSTATUS IN ('1','4','7')
         and UPPER(NVL(fld.CVALUE,'0000')) LIKE V_STRHDNUM
         AND se.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND se.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')

         ) SE ,  (SELECT * FROM VW_TLLOGFLD_ALL WHERE FLDCD='55') mor, issuers iss,
         (select nVL(SB1.Parvalue,SB.Parvalue) Parvalue,  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
    nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID, sb.symbol symbol1, sb.issuerid issuerid
from sbsecurities sb, sbsecurities sb1
where nvl(sb.refcodeid,' ') = sb1.codeid(+)) sb,
         afmast af,
         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
         where se.codeid = sb.codeid
         AND se.acctno = af.acctno
         AND af.custid = cf.custid
         AND AF.ACTYPE NOT IN ('0000')
        -- AND sb.tradeplace IN ('001', '002', '005')
         and se.txnum = mor.txnum  AND SE.TXDATE=MOR.TXDATE
         and sb.issuerid = iss.issuerid
         AND Cf.CUSTODYCD  LIKE V_CUSTODYCD
         AND sb.symbol     LIKE V_SYMBOL
         AND sb.tradeplace like V_TRADEPLACE

      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
