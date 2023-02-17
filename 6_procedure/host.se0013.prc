SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0013" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   CUSTODYCD        IN       VARCHAR2,
   AFACCTNO         IN       VARCHAR2,
   SYMBOL           IN       VARCHAR2,
   MAKER            IN       VARCHAR2,
   CHECKER          IN       VARCHAR2,
   TLID             IN       VARCHAR2,
   TLTXCD           IN       VARCHAR2
        )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
-- BAO CAO DANH SACH GIAO DICH LUU KY
-- Purpose: Briefly explain the functionality of the procedure
-- DANH SACH GIAO DICH LUU KY
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- DUNGNH   14-SEP-09  MODIFIED
-- ---------   ------  -------------------------------------------

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
    V_STRTLTXCD         VARCHAR (900);
    V_STRTMPTLTXCD_1      VARCHAR (900);
    V_STRTMPTLTXCD_2      VARCHAR (900);
    V_STRTMPTLTXCD_3      VARCHAR (900);
    V_STRTMPTLTXCD_4      VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCUSTODYCD          VARCHAR(20);
    V_STRAFACCTNO          VARCHAR(20);
    V_STRTLID           VARCHAR2(6);
    V_TLTXCD            VARCHAR2(10);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STRTLID:= TLID;
   V_STROPTION := OPT;

    V_STROPTION := OPT;
    IF (TLTXCD IS NULL OR UPPER(TLTXCD) = 'ALL') THEN
        V_TLTXCD := '%';
    ELSE
        V_TLTXCD := TLTXCD;
    END IF;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(PV_BRID,1,2) || '__' ;
    else
        V_STRBRID:=PV_BRID;
    END IF;

   IF  (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := replace(SYMBOL,' ','_');
   ELSE
      V_STRSYMBOL := '%%';
   END IF;
   --V_STRSYMBOL := Replace(V_STRSYMBOL,'_','');
   --V_STRSYMBOL := Trim(V_STRSYMBOL);

   --V_STRTLTXCD := TLTXCD;



   IF(CHECKER <> 'ALL')
   THEN
        V_STRCHECKER := CHECKER;
   ELSE
        V_STRCHECKER := '%%';
   END IF;

   IF(MAKER <> 'ALL')
   THEN
        V_STRMAKER  := MAKER;
   ELSE
        V_STRMAKER  := '%%';
   END IF;

   IF(CUSTODYCD <> 'ALL')
   THEN
        V_STRCUSTODYCD  := CUSTODYCD;
   ELSE
        V_STRCUSTODYCD  := '%%';
   END IF;

   IF(AFACCTNO <> 'ALL')
   THEN
        V_STRAFACCTNO  := AFACCTNO;
   ELSE
        V_STRAFACCTNO  := '%%';
   END IF;

----    ('2240','2230','2241','2231','2246')


OPEN PV_REFCURSOR FOR
select * from (
SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, TLG.TXNUM, TLG.TLTXCD, TLG.TLID,
    NVL(TLG.OFFID,' ') OFFID, TLG.BUSDATE, TLG.TXDESC, SB.SYMBOL, TLG.TXDATE,
    (CASE WHEN FLD1.FLDCD='06' THEN 'TRADE' ELSE 'BLOCKED' END) FIELD ,
    SE.NAMT MSGAMT,FLD1.NVALUE, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name,'' cvalue
FROM AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,
    SBSECURITIES SB, vw_setran_gen se, vw_tllog_all TLG
    left join
    (
    select * from tllogfldall
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    union all
    select * from tllogfld
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    )tlf
    on tlg.txnum = tlf.txnum and tlg.txdate = tlf.txdate
        left join
    (
    select * from tllogfldall
    where fldcd IN ('06','04') and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    union all
    select * from tllogfld
    where fldcd IN ('06','04') and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    )FLD1 ON  tlg.txnum = FLD1.txnum and tlg.txdate = FLD1.txdate
    left join TLPROFILES TLP1
    on TLG.OFFID = TLP1.TLID
    left join TLPROFILES TLP
    on TLG.TLID = TLP.TLID
WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
               -- AND AF.ACTYPE NOT IN ('0000')
                AND TLG.TLTXCD = TL.TLTXCD
                AND TLG.txnum = SE.txnum
                AND TLG.txdate = SE.txdate
                AND SE.CODEID=SB.CODEID
                and tlg.tltxcd in ('2230','2241','2231')
                AND TLG.deltd <> 'Y'
                AND SE.FIELD IN ('DEPOSIT')
                AND FLD1.NVALUE >0
                AND TLG.TLTXCD LIKE V_TLTXCD
                AND TLG.tlid LIKE V_STRMAKER
                AND (TLG.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
                AND TLG.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')  AND se.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                AND TLG.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')  AND se.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                AND TLG.deltd <> 'Y'
                AND substr(TLG.msgacct,1, 4) LIKE V_STRBRID
        and   NVL( SB.SYMBOL,'-') like V_STRSYMBOL and TLG.TLID LIKE V_STRMAKER
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD AND AF.ACCTNO LIKE V_STRAFACCTNO
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid like V_STRTLID )

UNION ALL


SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, TLG.TXNUM, TLG.TLTXCD, TLG.TLID,
    NVL(TLG.OFFID,' ') OFFID, TLG.BUSDATE, TLG.TXDESC, SB.SYMBOL, TLG.TXDATE,   (CASE WHEN FLD1.FLDCD='06' THEN 'TRADE' ELSE 'BLOCKED' END) FIELD ,
    SE.NAMT MSGAMT,FLD1.NVALUE, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name,tlf.cvalue cvalue
FROM AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,
    SBSECURITIES SB, vw_setran_gen se, vw_tllog_all TLG
    left join
    (
    select * from tllogfldall
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    union all
    select * from tllogfld
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    )tlf
    on tlg.txnum = tlf.txnum and tlg.txdate = tlf.txdate
        left join
    (
    select * from tllogfldall
    where fldcd IN ('06','07') and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    union all
    select * from tllogfld
    where fldcd IN ('06','07') and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    )FLD1 ON  tlg.txnum = FLD1.txnum and tlg.txdate = FLD1.txdate
    left join TLPROFILES TLP1
    on TLG.OFFID = TLP1.TLID
    left join TLPROFILES TLP
    on TLG.TLID = TLP.TLID
WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
              --  AND AF.ACTYPE NOT IN ('0000')
                AND TLG.TLTXCD = TL.TLTXCD
                AND TLG.txnum = SE.txnum
                AND TLG.txdate = SE.txdate
                AND SE.CODEID=SB.CODEID
                and tlg.tltxcd in ('2240')
                AND TLG.deltd <> 'Y'
                AND SE.FIELD IN ('DEPOSIT')
                AND FLD1.NVALUE >0
                AND TLG.TLTXCD LIKE V_TLTXCD
                AND TLG.tlid LIKE V_STRMAKER
                AND (TLG.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
                AND TLG.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')  AND se.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                AND TLG.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')  AND se.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                AND TLG.deltd <> 'Y'
                AND substr(TLG.msgacct,1, 4) LIKE V_STRBRID
        and   NVL( SB.SYMBOL,'-') like V_STRSYMBOL and TLG.TLID LIKE V_STRMAKER
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD AND AF.ACCTNO LIKE V_STRAFACCTNO
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid like V_STRTLID )

UNION ALL


SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, TLG.TXNUM, TLG.TLTXCD, TLG.TLID,
    NVL(TLG.OFFID,' ') OFFID, TLG.BUSDATE, TLG.TXDESC, SB.SYMBOL, TLG.TXDATE, SE.field,
    SE.NAMT MSGAMT,   SE.NAMT NVALUE, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name, '' cvalue
FROM AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,
    SBSECURITIES SB, vw_setran_gen se, vw_tllog_all TLG
    left join
    (
    select * from tllogfldall
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    union all
    select * from tllogfld
    where fldcd = '99' and txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY') and txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
    )tlf
    on tlg.txnum = tlf.txnum and tlg.txdate = tlf.txdate
    left join TLPROFILES TLP1
    on TLG.OFFID = TLP1.TLID
    left join TLPROFILES TLP
    on TLG.TLID = TLP.TLID
WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
              --  AND AF.ACTYPE NOT IN ('0000')
                AND TLG.TLTXCD = TL.TLTXCD
                AND TLG.txnum = SE.txnum
                AND TLG.txdate = SE.txdate
                AND SE.CODEID=SB.CODEID
                and tlg.tltxcd in ('2246')
                AND TLG.deltd <> 'Y'
                AND SE.FIELD IN ('TRADE','BLOCKED')
                AND  SE.NAMT>0
                AND TLG.TLTXCD LIKE V_TLTXCD
                AND TLG.tlid LIKE V_STRMAKER
                AND (TLG.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
                AND TLG.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')  AND se.busdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
                AND TLG.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')  AND se.busdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
                AND TLG.deltd <> 'Y'
                AND substr(TLG.msgacct,1, 4) LIKE V_STRBRID
        and   NVL( SB.SYMBOL,'-') like V_STRSYMBOL and TLG.TLID LIKE V_STRMAKER
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD AND AF.ACCTNO LIKE V_STRAFACCTNO
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid like V_STRTLID ))
            order by FIELD, tltxcd, txdate,custodycd
        ;


EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
 
 
 
/
