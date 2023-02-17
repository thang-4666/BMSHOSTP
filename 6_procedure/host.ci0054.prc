SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0054"
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
   PV_AFTYPE      IN       VARCHAR2

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
---

   IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      L_STRAFTYPE := '%';
   ELSE
      L_STRAFTYPE := PV_AFTYPE;
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
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;
     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR
    SELECT tr.TLTXCD, tr.CVALUE BANKCODE, BANK.FULLNAME BANKNAME,
        tr.BUSDATE, tr.TXNUM, CF.FULLNAME, CF.CUSTODYCD, AF.ACCTNO, tr.msgamt NAMT,
        tr.TXDESC, 'C' TXTYPE, tr.txdate,AL.CDCONTENT mnemonic,BR.brname,TR.MAKED,TR.APPROVE
    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
     BANKNOSTRO BANK, afmast af,AFTYPE AFT, ALLCODE AL,BRGRP BR,
    (
        SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.cvalue , tl.tlid, tl.offid,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate,TLP1.TLNAME MAKED ,TLP2.TLNAME APPROVE
        FROM TLLOGFLD fld, tllog tl, TLPROFILES TLP1,TLPROFILES TLP2
        where fld.FLDCD = '02'
            and tl.tltxcd = '1141'
            and fld.txnum = tl.txnum
            and fld.txdate = tl.txdate
             AND TL.TLID =TLP1.TLID(+)
             AND TL.offid =TLP2.TLID(+)
            AND tl.BUSDATE <= v_T_date
            AND tl.BUSDATE >= v_F_date
            and tl.deltd = 'Y'
            and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
            AND fld.CVALUE LIKE v_BANKCODE
        UNION ALL
        SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.cvalue, tl.tlid, tl.offid,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate,TLP1.TLNAME MAKED ,TLP2.TLNAME APPROVE
        FROM TLLOGFLDALL fld, tllogall tl, TLPROFILES TLP1,TLPROFILES TLP2
        where fld.FLDCD = '02'
            and tl.tltxcd = '1141'
            and fld.txnum = tl.txnum
            and fld.txdate = tl.txdate
             AND TL.TLID =TLP1.TLID(+)
             AND TL.offid =TLP2.TLID(+)
            AND tl.BUSDATE <= v_T_date
            AND tl.BUSDATE >= v_F_date
            and tl.deltd = 'Y'
            and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
            AND fld.CVALUE LIKE v_BANKCODE
    ) tr
    WHERE tr.msgacct = af.acctno
         AND af.custid = cf.custid
         AND CF.brid =  BR.brid
         AND AF.ACTYPE=AFT.ACTYPE
         AND AL.CDTYPE='CF'
         AND AL.CDVAL=AFT.PRODUCTTYPE
         AND AL.CDNAME='PRODUCTTYPE'
         AND tr.CVALUE = BANK.SHORTNAME
         AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
         AND AF.ACCTNO LIKE V_STRAFACCTNO
         AND tr.tlid LIKE V_STRMAKER
         AND tr.offid LIKE V_STRCHECKER
         AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
         AND AFT.producttype LIKE L_STRAFTYPE
         ;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure

 
 
 
 
/
