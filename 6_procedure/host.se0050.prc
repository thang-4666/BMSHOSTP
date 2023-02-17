SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0050" (
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

-----------------
   IF  (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := replace(SYMBOL,' ','_');
   ELSE
      V_STRSYMBOL := '%%';
   END IF;
------------------
   IF(CHECKER <> 'ALL')
   THEN
        V_STRCHECKER := CHECKER;
   ELSE
        V_STRCHECKER := '%%';
   END IF;
-----------------
   IF(MAKER <> 'ALL')
   THEN
        V_STRMAKER  := MAKER;
   ELSE
        V_STRMAKER  := '%%';
   END IF;
---------------------
   IF(CUSTODYCD <> 'ALL')
   THEN
        V_STRCUSTODYCD  := CUSTODYCD;
   ELSE
        V_STRCUSTODYCD  := '%%';
   END IF;
---------------------
   IF(AFACCTNO <> 'ALL')
   THEN
        V_STRAFACCTNO  := AFACCTNO;
   ELSE
        V_STRAFACCTNO  := '%%';
   END IF;

--------------------------------------

OPEN PV_REFCURSOR FOR

SELECT TLTXCD,TXNUM,TXDATE,BUSDATE,CUSTODYCD,FULLNAME,ACCTNO,MAKER,CHECKER,TLTXCD_NAME,CAMKET,FIELD,SO_LUONG,SYMBOL,TT FROM(
--gui
SELECT TLTXCD,TXNUM,TXDATE,BUSDATE,CUSTODYCD,FULLNAME,ACCTNO,MAKER,CHECKER,TLTXCD_NAME,CAMKET,FIELD,SO_LUONG,SYMBOL,
(CASE WHEN LOAI IS NULL THEN 'N' ELSE 'Y' END ) TT
FROM(  --LAM 2240
        SELECT A.*,NVL(C.AUTOID,'') LOAI
        FROM
               (SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, SE.TXNUM, SE.TLTXCD, SE.TLID,
                         SED.ACCTNO MSGACCT,NVL(SE.OFFID,' ') OFFID, SE.BUSDATE, SE.TXDESC, SB.SYMBOL, SE.TXDATE,
                        (CASE WHEN FLD1.FLDCD='06' THEN 'TRADE' ELSE 'BLOCKED' END) FIELD ,
                         FLD1.NVALUE SO_LUONG, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name,tlf.cvalue CAMKET
                FROM AFMAST AF,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,SBSECURITIES SB,SEDEPOSIT SED, vw_setran_gen se
                left join
                   (select * from tllogfldall where fldcd = '99' union all select * from tllogfld where fldcd = '99' )tlf
                   on SE.txnum = tlf.txnum and SE.txdate = tlf.txdate
                left join
                  (select * from tllogfldall where fldcd IN ('06','07') union all select * from tllogfld where fldcd IN ('06','07'))FLD1
                   ON  SE.txnum = FLD1.txnum and SE.txdate = FLD1.txdate
                left join TLPROFILES TLP1 on SE.OFFID = TLP1.TLID
                left join TLPROFILES TLP on SE.TLID = TLP.TLID
         WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
                AND AF.ACTYPE NOT IN ('0000') AND SE.TLTXCD = TL.TLTXCD
                AND SE.txnum = SED.txnum AND SE.txdate = SED.txdate
                AND SE.CODEID=SB.CODEID and SE.tltxcd in ('2240')
                AND SED.deltd <> 'Y' AND SE.FIELD IN ('DEPOSIT')
                AND SE.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and SE.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                AND FLD1.NVALUE >0)A,

         --LAM 2246
         (SELECT SEDE.AUTOID,SEDE.ACCTNO,SEDE.TXNUM,SEDE.DEPOSITQTTY,SEDE.TXDATE
                 FROM SEDEPOSIT SEDE, vw_tllog_all TLG
                  left join
                    (select autoid,txnum,txdate,nvalue from tllogfldall where fldcd = '05'  and nvalue>0  union all
                     select autoid,txnum,txdate,nvalue from tllogfld  where fldcd = '05'  and nvalue>0)tlf
                       on tlg.txnum = tlf.txnum and tlg.txdate = tlf.txdate

          WHERE  TLG.TLTXCD in ('2246') AND TLF.NVALUE=SEDE.AUTOID AND TLG.MSGACCT=SEDE.ACCTNO
           AND TLG.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and TLG.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')) C
WHERE A.TXNUM=C.TXNUM(+)
      AND A.TXDATE=C.TXDATE(+)
       AND A.TLTXCD LIKE V_TLTXCD
       AND A.tlid LIKE V_STRMAKER
       AND (A.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
       AND substr(A.ACCTNO,1, 4) LIKE V_STRBRID
       and   NVL( A.SYMBOL,'-') like V_STRSYMBOL and A.TLID LIKE V_STRMAKER
       AND A.CUSTODYCD LIKE V_STRCUSTODYCD AND A.ACCTNO LIKE V_STRAFACCTNO
       and exists (select gu.grpid from tlgrpusers gu where A.careby = gu.grpid and gu.tlid like V_STRTLID ))
UNION ALL
--rut
SELECT TLTXCD,TXNUM,TXDATE,BUSDATE,CUSTODYCD,FULLNAME,ACCTNO,MAKER,CHECKER,TLTXCD_NAME,CAMKET,FIELD,SO_LUONG,SYMBOL,
(CASE WHEN LOAI IS NULL THEN 'N'ELSE 'Y' END ) TT
FROM(
        SELECT A.*,NVL(C.STATUS,'') LOAI
        FROM (
        --LAM 2200
        SELECT FULLNAME,careby,ACCTNO,CUSTODYCD,TXNUM,TLTXCD,TLID,AFACCTNO,OFFID,BUSDATE,TXDESC,SYMBOL, TXDATE, FIELD ,
           SO_LUONG, MAKER , CHECKER,tltxcd_name,NVL(CAMKET,'') CAMKET
           FROM(  SELECT TA.*,NVL(HUY.STA,'I') STA
           FROM ( SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, SE.TXNUM, SE.TLTXCD, SE.TLID,
                        SE.AFACCTNO,NVL(SE.OFFID,' ') OFFID, SE.BUSDATE, SE.TXDESC, SB.SYMBOL, SE.TXDATE, SE.FIELD ,
                         SE.NAMT SO_LUONG, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name,'' CAMKET
                FROM AFMAST AF,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,SBSECURITIES SB, vw_setran_gen se

                left join TLPROFILES TLP1 on SE.OFFID = TLP1.TLID
                left join TLPROFILES TLP on SE.TLID = TLP.TLID
         WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
                AND AF.ACTYPE NOT IN ('0000') AND SE.TLTXCD = TL.TLTXCD
                AND SE.CODEID=SB.CODEID and SE.tltxcd in ('2200')
                AND SE.deltd <> 'Y' AND SE.FIELD IN ('TRADE','BLOCKED')
                 AND SE.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and SE.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')) TA,
                 --LAM HUY 2293
                (SELECT DISTINCT SEDE.TXDATE,SEDE.TXNUM,'A' STA
                 FROM SEWITHDRAWDTL SEDE, vw_tllog_all TL, VW_TLLOGFLD_ALL FLD
                  WHERE  TL.TLTXCD in ('2293') AND TL.TXNUM=FLD.TXNUM AND TL.TXDATE=FLD.TXDATE
                  AND FLD.FLDCD='07' AND SEDE.TXDATETXNUM=FLD.CVALUE(+) AND SEDE.DELTD<>'Y'
                  AND TL.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and TL.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                    ) HUY
                    WHERE  TA.TXNUM=HUY.TXNUM(+)
                      AND TA.TXDATE=HUY.TXDATE(+))
                         WHERE STA='I')A,
            --LAM 2201
           (SELECT DISTINCT SEDE.TXDATE,SEDE.ACCTNO,SEDE.TXNUM,SEDE.STATUS
                 FROM SEWITHDRAWDTL SEDE, vw_tllog_all TL, VW_TLLOGFLD_ALL FLD
                  WHERE  TL.TLTXCD in ('2201') AND TL.TXNUM=FLD.TXNUM AND TL.TXDATE=FLD.TXDATE
                  AND FLD.FLDCD='07' AND SEDE.TXDATETXNUM=FLD.CVALUE(+) AND SEDE.DELTD<>'Y'
                   AND TL.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and TL.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                    ) C


WHERE  A.TXNUM=C.TXNUM(+)
      AND A.TXDATE=C.TXDATE(+)
       AND A.TLTXCD LIKE V_TLTXCD
       AND A.tlid LIKE V_STRMAKER
       AND (A.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
       AND substr(A.ACCTNO,1, 4) LIKE V_STRBRID
       and   NVL( A.SYMBOL,'-') like V_STRSYMBOL and A.TLID LIKE V_STRMAKER
       AND A.CUSTODYCD LIKE V_STRCUSTODYCD AND A.ACCTNO LIKE V_STRAFACCTNO
       and exists (select gu.grpid from tlgrpusers gu where A.careby = gu.grpid and gu.tlid like V_STRTLID )
      )
UNION ALL
--Chuyen
SELECT  TLTXCD,TXNUM,TXDATE,BUSDATE,CUSTODYCD,FULLNAME,ACCTNO,MAKER,CHECKER,TLTXCD_NAME,CAMKET,FIELD,SO_LUONG,SYMBOL,
        (CASE WHEN LOAI IS NULL THEN 'N'ELSE 'Y' END ) TT
FROM(
         SELECT A.*,NVL(C.STATUS,'') LOAI
        FROM ( --LAM 2244
         SELECT FULLNAME,careby,ACCTNO,CUSTODYCD,TXNUM,TLTXCD,TLID,
                 AFACCTNO,OFFID,BUSDATE,TXDESC,SYMBOL, TXDATE, FIELD ,
                  SO_LUONG, MAKER , CHECKER,tltxcd_name,NVL(CAMKET,'') CAMKET
                   FROM(  SELECT TA.*,NVL(HUY.STA,'I') STA
                   FROM ( SELECT  DISTINCT CF.FULLNAME, af.careby, AF.ACCTNO, CF.CUSTODYCD, SE.TXNUM, SE.TLTXCD, SE.TLID,
                        SE.AFACCTNO,NVL(SE.OFFID,'') OFFID, SE.BUSDATE, SE.TXDESC, SB.SYMBOL, SE.TXDATE, SE.FIELD ,
                         SE.NAMT SO_LUONG, TLP.TLNAME MAKER , TLP1.TLNAME CHECKER, tl.txdesc tltxcd_name,'' CAMKET
                FROM AFMAST AF,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, TLTX TL,SBSECURITIES SB, vw_setran_gen se
                left join TLPROFILES TLP1 on SE.OFFID = TLP1.TLID
                left join TLPROFILES TLP on SE.TLID = TLP.TLID
         WHERE AF.CUSTID = CF.CUSTID AND SE.CUSTID = CF.CUSTID and af.acctno = se.afacctno
                AND AF.ACTYPE NOT IN ('0000') AND SE.TLTXCD = TL.TLTXCD
                AND SE.CODEID=SB.CODEID and SE.tltxcd in ('2244')
                AND SE.deltd <> 'Y' AND SE.FIELD IN ('TRADE','BLOCKED')
                 AND SE.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and SE.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                 ) TA,
                 --LAM 2254
           (SELECT DISTINCT SEDE.TXDATE,SEDE.TXNUM,'A' STA
                 FROM sesendout SEDE, VW_SETRAN_GEN TL, VW_TLLOGFLD_ALL FLD
                  WHERE  TL.TLTXCD in ('2254') AND TL.TXNUM=FLD.TXNUM AND TL.TXDATE=FLD.TXDATE
                  AND FLD.FLDCD='18' AND SEDE.AUTOID=fld.nvalue(+) AND SEDE.DELTD<>'Y'
                   AND TL.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and TL.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                    ) HUY
                    WHERE  TA.TXNUM=HUY.TXNUM(+)
                     AND TA.TXDATE=HUY.TXDATE(+))
                      WHERE STA='I')A,
            --LAM 2266
           (SELECT DISTINCT SEDE.TXDATE,SEDE.ACCTNO,SEDE.TXNUM,SEDE.STATUS
                 FROM sesendout SEDE, VW_SETRAN_GEN TL, VW_TLLOGFLD_ALL FLD
                  WHERE  TL.TLTXCD in ('2266') AND TL.TXNUM=FLD.TXNUM AND TL.TXDATE=FLD.TXDATE
                  AND FLD.FLDCD='18' AND SEDE.AUTOID=fld.nvalue(+) AND SEDE.DELTD<>'Y'
                   AND TL.TXDATE>=TO_DATE (F_DATE,'DD/MM/YYYY') and TL.txdate <= TO_DATE (T_DATE,'DD/MM/YYYY')
                    ) C

WHERE  A.TXNUM=C.TXNUM(+)
       AND A.TXDATE=C.TXDATE(+)
       AND A.TLTXCD LIKE V_TLTXCD
       AND A.tlid LIKE V_STRMAKER
       AND (A.offid LIKE V_STRCHECKER or V_STRCHECKER='%%')
       AND substr(A.ACCTNO,1, 4) LIKE V_STRBRID
       and   NVL( A.SYMBOL,'-') like V_STRSYMBOL and A.TLID LIKE V_STRMAKER
       AND A.CUSTODYCD LIKE V_STRCUSTODYCD AND A.ACCTNO LIKE V_STRAFACCTNO
       and exists (select gu.grpid from tlgrpusers gu where A.careby = gu.grpid and gu.tlid like V_STRTLID )))
WHERE TT='N'
ORDER BY TXDATE,TLTXCD,CUSTODYCD,FIELD
;

EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
 
 
 
/
