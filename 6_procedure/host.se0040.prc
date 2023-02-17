SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0040 (
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

-- RP NAME : BANG KE CHUNG KHOAN GIAI TOA CAM CO 21B/LK
-- PERSON : QUYET.KIEU
-- DATE :   07/05/2011
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
SELECT  V_STRPLSENT PLSENT,A.SAN, A.FULLNAME, A.SO_TK_LUUKY, A.IDCODE, A.NGAY_CAP, A.AFACCTNO, A.NGAY_GIAI_TOA, A.CODEID, A.MA_CK, A.MENH_GIA, A.SOLUONG, A.TXNUM, B.BEN_GIAI_TOA_CAM_CO,B.Ngay_hop_dong_camco, B.So_hop_dong_camco FROM
    (
    Select
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
          tl.txdate Ngay_giai_toa,
         (CASE WHEN instr(sb.symbol1,'_WFT') <> 0 then '7' else '1' end) Codeid ,
         sb.symbol Ma_CK,
         (nvl(sb.Parvalue,0)) Menh_Gia
         ,nvl(tl.msgamt,0) soluong
        ,tl.txnum, SE1.AUTOID
    from  semast se,
            (select nVL(SB1.Parvalue,SB.Parvalue) Parvalue,  NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
                nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID, sb.symbol symbol1
                    from sbsecurities sb, sbsecurities sb1
                        where nvl(sb.refcodeid,' ') = sb1.codeid(+)) sb,
            afmast af,
            (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
            (select * from tllog union select * from tllogall) tl, VW_TLLOGFLD_ALL FLD, SEMORTAGE SE1, SEMORTAGE SE2
    where   se.codeid = sb.codeid
        AND se.afacctno = af.acctno
        AND af.custid = cf.custid
       -- AND AF.ACTYPE NOT IN ('0000')
       -- AND sb.tradeplace IN ('001', '002', '005')
        and tl.tltxcd = '2233'
        and se.acctno = tl.msgacct
        and tl.deltd<>'Y'
        AND TL.TXSTATUS in ('4','7','1')
        AND TL.TXNUM=FLD.TXNUM
        AND TL.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='50'
        AND FLD.NVALUE=SE1.AUTOID
        AND TL.TXNUM=SE2.TXNUM(+)
        AND TL.TXDATE=SE2.TXDATE(+)
        AND SE1.DELTD<>'Y' AND NVL(SE2.DELTD,'N')<>'Y'
        AND UPPER(NVL(SE1.NUM_MG,'0000')) LIKE V_STRHDNUM
        and Cf.CUSTODYCD  like V_CUSTODYCD
        and sb.symbol     like V_SYMBOL
        and sb.tradeplace like V_TRADEPLACE
    ) A,
    (select AUTOID,crfullname BEN_GIAI_TOA_CAM_CO, to_char(mor.mdate,'DD/MM/RRRR') Ngay_hop_dong_camco, mor.num_mg So_hop_dong_camco
        from semortage mor where tltxcd = '2232' and status = 'C'
    ) B
WHERE B.AUTOID = A.AUTOID
      AND A.NGAY_GIAI_TOA >= TO_DATE (f_date, 'DD/MM/YYYY')
      AND A.NGAY_GIAI_TOA <= TO_DATE (t_date, 'DD/MM/YYYY');
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
