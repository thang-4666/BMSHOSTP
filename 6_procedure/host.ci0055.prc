SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0055
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_BANKCODE    IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_MAKER       IN       VARCHAR2,
   PV_CHECKER     IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_STATUS       IN      VARCHAR2

   ) IS

   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(5);

   v_BANKCODE       VARCHAR2(500);
   V_F_DATE         date;
   V_T_DATE         date;

   V_STRCUSTODYCD   VARCHAR2(20);
   V_STRAFACCTNO    VARCHAR2(20);

   V_STRMAKER       VARCHAR2(20);
   V_STRCHECKER     VARCHAR2(20);

   L_STRAFTYPE        varchar2(20);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_STATUS         VARCHAR2(100);
   V_BANK               VARCHAR2(100);
BEGIN

    V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    v_F_date := to_date(F_DATE,'dd/mm/rrrr');
    v_T_date := to_date(T_DATE,'dd/mm/rrrr');

    if(upper(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1 )then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    end if;

    if(upper(PV_AFACCTNO) = 'ALL' OR LENGTH(PV_AFACCTNO) < 1 )then
        V_STRAFACCTNO := '%';
    else
        V_STRAFACCTNO := UPPER(PV_AFACCTNO);
    end if;

    if(upper(PV_MAKER) = 'ALL' OR LENGTH(PV_MAKER) < 1 )then
        V_STRMAKER := '%';
    else
        V_STRMAKER := UPPER(PV_MAKER);
    end if;

    if(upper(PV_CHECKER) = 'ALL' OR LENGTH(PV_CHECKER) < 1 )then
        V_STRCHECKER := '%';
    else
        V_STRCHECKER := UPPER(PV_CHECKER);
    end if;


    IF (UPPER(PV_BANKCODE) = 'ALL' OR LENGTH(PV_BANKCODE) < 1) THEN
         v_BANKCODE := '%%';
    ELSE
       v_BANKCODE := PV_BANKCODE;
    END IF;

         IF (UPPER(PV_BANKCODE) = 'ALL' OR LENGTH(PV_BANKCODE) < 1) THEN
         v_BANK := '%';
    ELSE
       SELECT BANKACCTNO INTO V_BANK FROM BANKNOSTRO WHERE SHORTNAME=PV_BANKCODE;
    END IF;
---

   IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      L_STRAFTYPE := '%';
   ELSE
      L_STRAFTYPE := PV_AFTYPE;
   END IF;

   IF (PV_STATUS IS NULL OR UPPER(PV_STATUS) = 'ALL')
   THEN
      V_STATUS := '%';
   ELSE
      V_STATUS := PV_STATUS;
   END IF;

      IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   /*IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' To?c?ty ';
   END IF;*/
     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR
    SELECT v_BANK CUST,tr.TLTXCD, tr.CVALUE BANKCODE, nvl(BANK.FULLNAME,'TCÄT') BANKNAME,to_char(TR.DATE_NH) DATE_NH,
        tr.BUSDATE, tr.TXNUM, CF.FULLNAME, CF.CUSTODYCD, AF.ACCTNO, tr.msgamt NAMT, cf.brid,
        tr.TXDESC, 'C' TXTYPE, tr.txdate,AL.CDCONTENT mnemonic,BR.brname,TR.MAKED,TR.APPROVE,TR.DELTD
    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
     BANKNOSTRO BANK, afmast af,AFTYPE AFT, ALLCODE AL,BRGRP BR,
    (
         SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.cvalue , tl.tlid, tl.offid,NVL(FLD1.CVALUE,'') DATE_NH,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate,TLP1.TLNAME MAKED ,TLP2.TLNAME APPROVE,
             (CASE WHEN tl.deltd = 'N' AND TL.TXSTATUS = '4' THEN 'P'
                WHEN tl.deltd = 'N' AND TL.TXSTATUS IN ('1','7') THEN 'A'
                ELSE  'C' END) deltd
        FROM (SELECT * FROM tllogfld WHERE FLDCD='05') fld, (SELECT * FROM TLLOG where tltxcd = '1196') tl,
            TLPROFILES TLP1,TLPROFILES TLP2,
             (SELECT * FROM tllogfld WHERE FLDCD='32') FLD1
        where fld.txnum = tl.txnum
            and fld.txdate = tl.txdate
            and TL.txnum = FLD1.txnum(+)
            and TL.txdate = FLD1.txdate(+)
            AND TL.TLID =TLP1.TLID(+)
            AND TL.offid =TLP2.TLID(+)
            AND tl.BUSDATE <= v_T_date
            AND tl.BUSDATE >= v_F_date
    ) tr
    WHERE tr.msgacct = af.acctno
         AND af.custid = cf.custid
         AND CF.brid =  BR.brid
         AND AF.ACTYPE=AFT.ACTYPE
         AND AL.CDTYPE='CF'
         AND AL.CDVAL=AFT.PRODUCTTYPE
         AND AL.CDNAME='PRODUCTTYPE'
         AND tr.CVALUE = BANK.BANKACCTNO(+)
         AND TR.DELTD LIKE V_STATUS
         AND nvl(BANK.SHORTNAME,'000') LIKE v_BANKCODE
         AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
         AND AF.ACCTNO LIKE V_STRAFACCTNO
         AND nvl(tr.tlid,'0000') LIKE V_STRMAKER
         AND nvl(tr.offid,'0000') LIKE V_STRCHECKER
         AND CF.BRID LIKE V_I_BRIDGD
         AND AFT.producttype LIKE L_STRAFTYPE
    union all
 SELECT v_BANK CUST,tr.TLTXCD, tr.CVALUE BANKCODE, nvl(BANK.FULLNAME,'TCÄT') BANKNAME,to_char(TR.DATE_NH) DATE_NH,
        tr.BUSDATE, tr.TXNUM, CF.FULLNAME, CF.CUSTODYCD, AF.ACCTNO, tr.msgamt NAMT, cf.brid,
        tr.TXDESC, 'C' TXTYPE, tr.txdate,AL.CDCONTENT mnemonic,BR.brname,TR.MAKED,TR.APPROVE,TR.DELTD
    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
     BANKNOSTRO BANK, afmast af,AFTYPE AFT, ALLCODE AL,BRGRP BR,
    (
         SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.bankacctno cvalue , tl.tlid, tl.offid,NVL(FLD.refdate,'') DATE_NH,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate,TLP1.TLNAME MAKED ,TLP2.TLNAME APPROVE,
            (CASE WHEN tl.deltd = 'N' AND TL.TXSTATUS = '4' THEN 'P'
                WHEN tl.deltd = 'N' AND TL.TXSTATUS IN ('1','7') THEN 'A'
                ELSE  'C' END) deltd
        FROM (SELECT * FROM TLLOGALL where tltxcd = '1196' and BUSDATE <= v_T_date
            AND BUSDATE >= v_F_date) tl,
            TLPROFILES TLP1,TLPROFILES TLP2,
             tblcashdeposithist FLD
        where tl.txnum = fld.txnum (+)
            and tl.txdate = fld.txdate (+)
            AND TL.TLID = TLP1.TLID (+)
            AND TL.offid = TLP2.TLID (+)
    ) tr
    WHERE tr.msgacct = af.acctno
         AND af.custid = cf.custid
         AND CF.brid =  BR.brid
         AND AF.ACTYPE=AFT.ACTYPE
         AND AL.CDTYPE='CF'
         AND AL.CDVAL=AFT.PRODUCTTYPE
         AND AL.CDNAME='PRODUCTTYPE'
         AND tr.CVALUE = BANK.BANKACCTNO(+)
         AND TR.DELTD LIKE V_STATUS
         AND nvl(BANK.SHORTNAME,'000') LIKE v_BANKCODE
         AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
         AND AF.ACCTNO LIKE V_STRAFACCTNO
         AND nvl(tr.tlid,'0000') LIKE V_STRMAKER
         AND nvl(tr.offid,'0000') LIKE V_STRCHECKER
         AND CF.BRID LIKE V_I_BRIDGD
         AND AFT.producttype LIKE L_STRAFTYPE
         ;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure

 
 
 
 
/
