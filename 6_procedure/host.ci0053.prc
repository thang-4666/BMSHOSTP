SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0053"
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
   PV_CHECKER     IN       VARCHAR2
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

     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR
    SELECT tr.TLTXCD, tr.CVALUE BANKCODE, tr.CVALUE BANKNAME,
        tr.BUSDATE, tr.TXNUM, CF.FULLNAME, CF.CUSTODYCD, AF.ACCTNO, tr.msgamt NAMT,
        tr.TXDESC, 'C' TXTYPE, tr.txdate
    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, afmast af,
    (
        SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.cvalue , tl.tlid, tl.offid,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate
        FROM TLLOGFLD fld, tllog tl
        where fld.FLDCD = '80'
            and tl.tltxcd = '1139'
            and fld.txnum = tl.txnum
            and fld.txdate = tl.txdate
            AND tl.BUSDATE <= v_T_date
            AND tl.BUSDATE >= v_F_date
            and tl.deltd <> 'Y'
            and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
            AND fld.CVALUE LIKE v_BANKCODE
        UNION ALL
        SELECT tl.busdate, tl.msgacct, tl.msgamt, fld.cvalue, tl.tlid, tl.offid,
            tl.TLTXCD, tl.txnum, tl.txdesc, tl.txdate
        FROM TLLOGFLDALL fld, tllogall tl
        where fld.FLDCD = '80'
            and tl.tltxcd = '1139'
            and fld.txnum = tl.txnum
            and fld.txdate = tl.txdate
            AND tl.BUSDATE <= v_T_date
            AND tl.BUSDATE >= v_F_date
            and tl.deltd <> 'Y'
            and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
            AND fld.CVALUE LIKE v_BANKCODE
    ) tr
    WHERE tr.msgacct = af.acctno
        and af.custid = cf.custid
        AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
        AND AF.ACCTNO LIKE V_STRAFACCTNO
        AND tr.tlid LIKE V_STRMAKER
        AND tr.offid LIKE V_STRCHECKER;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure

 
 
 
 
/
