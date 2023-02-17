SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se1088 (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS          IN       VARCHAR2,
   TLSCOPE          IN       VARCHAR2,
   TYPEDATE         IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   CUSTODYCD        IN       VARCHAR2,
   AFACCTNO         IN       VARCHAR2,
   SYMBOL           IN       VARCHAR2,
   MAKER            IN       VARCHAR2,
   CHECKER          IN       VARCHAR2,
   PV_TLTXCD        IN       VARCHAR2,
   PV_AFTYPE        IN       VARCHAR2,
   PV_BAL_TYPE      IN       VARCHAR2,
   I_BRIDGD         IN       VARCHAR2,
   PV_STATUS        IN       VARCHAR2
        )
   IS

--

-- ---------   ------  -------------------------------------------

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCUSTODYCD          VARCHAR(20);
    V_STRAFACCTNO          VARCHAR(20);
    V_STRTLID           VARCHAR2(6);
    V_TLTXCD            VARCHAR2(10);
    V_AFTYPE              VARCHAR(100);
    V_TYPE               VARCHAR(100);

    V_I_BRID        VARCHAR2(100);
    V_STATUS       VARCHAR2(100);
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STROPTION := OPT;

    V_STROPTION := OPT;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(pv_BRID,1,2) || '__' ;
    else
        V_STRBRID:=pv_BRID;
    END IF;

------------
    IF (PV_TLTXCD IS NULL OR UPPER(PV_TLTXCD) = 'ALL') THEN
        V_TLTXCD := '%';
    ELSE
        V_TLTXCD := PV_TLTXCD;
    END IF;
    -------------

    V_STRTYPEDATE:=TYPEDATE;

----------------
 IF(PV_AFTYPE <> 'ALL')
   THEN
        V_AFTYPE := PV_AFTYPE;
   ELSE
        V_AFTYPE := '%%';
   END IF;
   ----------------
 IF(PV_BAL_TYPE <> 'ALL')
   THEN
        V_TYPE := PV_BAL_TYPE;
   ELSE
        V_TYPE := '%%';
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
   ---------------------
   IF(I_BRIDGD <> 'ALL')
   THEN
        V_I_BRID  := I_BRIDGD;
   ELSE
        V_I_BRID  := '%%';
   END IF;

   ---------------------
   IF(PV_STATUS = 'ALL')
   THEN
        V_STATUS  := '%%';
   ELSE
        V_STATUS  :=PV_STATUS;
   END IF;

--------------------------------------
IF V_STRTYPEDATE='002' THEN

OPEN PV_REFCURSOR FOR

SELECT se.txnum,tl.tltxcd , tl.txdesc TEN_GD,NVL(TLP.TLNAME,'') MAKER , NVL(TLP1.TLNAME,'') CHECKER
, se.custodycd,se.afacctno acctno ,se.symbol , decode (se.txtype,'C',namt,0) cr, decode (se.txtype,'D',namt,0) dr,
seif.BASICPRICE,SE.BUSDATE,SE.TXDESC,A1.CDCONTENT DELTD,SE.TXDATE , A2.CDCONTENT FIELD,CF.FULLNAME
FROM vw_setran_gen_all se, tltx tl, tlprofiles tlp, tlprofiles tlp1,securities_info seif,allcode A1,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf,
allcode a2
where se.tltxcd = tl.tltxcd
and se.tlid = tlp.tlid(+)
and se.offid  = tlp1.tlid(+)
and se.codeid = seif.codeid
AND A1.CDVAL=( CASE WHEN SE.DELTD='Y' THEN '9' ELSE '1' END)
AND A1.CDTYPE='SY'
AND A1.CDNAME='TXSTATUS'
AND A2.CDVAL=SE.FIELD
AND A2.CDTYPE='SE'
AND A2.CDNAME='SEFIELDS'
and se.custid = cf.custid
AND SE.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE (T_DATE,'DD/MM/YYYY')
AND TL.TLTXCD LIKE V_TLTXCD
AND NVL(SE.tlid,'000')  LIKE V_STRMAKER
AND NVL(SE.offid,'000') LIKE V_STRCHECKER
AND NVL( SEIF.SYMBOL,'-') LIKE V_STRSYMBOL
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND se.ACCTNO LIKE V_STRAFACCTNO
AND CF.BRID LIKE V_I_BRID
AND SE.txstatus LIKE V_STATUS
order by se.txdate,se.txnum
;
ELSE

OPEN PV_REFCURSOR FOR

SELECT se.txnum,tl.tltxcd , tl.txdesc TEN_GD,NVL(TLP.TLNAME,'') MAKER , NVL(TLP1.TLNAME,'') CHECKER
, se.custodycd,se.afacctno acctno ,se.symbol , decode (se.txtype,'C',namt,0) cr, decode (se.txtype,'D',namt,0) dr,
seif.BASICPRICE,SE.BUSDATE,SE.TXDESC,A1.CDCONTENT DELTD,SE.TXDATE , A2.CDCONTENT FIELD,CF.FULLNAME
FROM vw_setran_gen_all se, tltx tl, tlprofiles tlp, tlprofiles tlp1,securities_info seif,allcode A1,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf,
allcode a2
where se.tltxcd = tl.tltxcd
and se.tlid = tlp.tlid(+)
and se.offid  = tlp1.tlid(+)
and se.codeid = seif.codeid
AND A1.CDVAL=( CASE WHEN SE.DELTD='Y' THEN '9' ELSE '1' END)
AND A1.CDTYPE='SY'
AND A1.CDNAME='TXSTATUS'
AND A2.CDVAL=SE.FIELD
AND A2.CDTYPE='SE'
AND A2.CDNAME='SEFIELDS'
and se.custid = cf.custid
AND SE.TXDATE BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE (T_DATE,'DD/MM/YYYY')
AND TL.TLTXCD LIKE V_TLTXCD
AND NVL(SE.tlid,'000')  LIKE V_STRMAKER
AND NVL(SE.offid,'000') LIKE V_STRCHECKER
AND NVL( SEIF.SYMBOL,'-') LIKE V_STRSYMBOL
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND se.ACCTNO LIKE V_STRAFACCTNO
AND CF.BRID LIKE V_I_BRID
AND SE.txstatus LIKE V_STATUS
order by se.txdate,se.txnum
;


END IF;
EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
 
 
 
/
