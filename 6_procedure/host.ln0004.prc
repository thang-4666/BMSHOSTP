SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_ACTYPE      IN       VARCHAR2,
   I_CUSTODYCD    IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   GRCAREBY       IN       VARCHAR2,
   PV_REID        IN       VARCHAR2,
   TLID            IN      VARCHAR2,
   DEALDAYS        IN      VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BANG KE PHAT VAY BAO LANH.
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   17-MAY-10  CREATED
-- HUONG.TTD 27-OCT-10 UPDATED (them ma giao dich)
-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
   V_STRI_CUSTODYCD VARCHAR2 (20);
   V_STRI_AFACCTNO  VARCHAR2 (20);
   V_STRBRGID  VARCHAR2 (10);
   V_STRI_ACTYPE        VARCHAR2(20);
   V_CAREBY             VARCHAR2 (20);
   V_REID           VARCHAR2(20);

   V_FROMDATE     DATE;
   V_TODATE       DATE;
   V_STRTLID           VARCHAR2(6);
   v_dealdays          NUMBER;

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   V_STRTLID:= TLID;
   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF(I_CUSTODYCD <> 'ALL') THEN
     V_STRI_CUSTODYCD := I_CUSTODYCD;
   ELSE
     V_STRI_CUSTODYCD := '%';
   END IF;

   IF(PV_AFACCTNO <> 'ALL') THEN
     V_STRI_AFACCTNO := PV_AFACCTNO;
   ELSE
     V_STRI_AFACCTNO := '%';
   END IF;

   IF(PV_ACTYPE <> 'ALL') THEN
      V_STRI_ACTYPE := PV_ACTYPE;
   ELSE
      V_STRI_ACTYPE := '%';
   END IF;

   IF (GRCAREBY <> 'ALL')
  THEN
     V_CAREBY := GRCAREBY;
  ELSE
      V_CAREBY := '%';
   END IF;

   IF (PV_REID <> 'ALL')
   THEN
      V_REID := PV_REID;
   ELSE
      V_REID := '%';
   END IF;

   V_FROMDATE  :=    TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE    :=    TO_DATE(T_DATE,'DD/MM/RRRR');
   v_dealdays:=to_number(DEALDAYS);

OPEN PV_REFCURSOR
FOR
  SELECT * FROM (
    SELECT to_char(SCHD.RLSDATE,'DD/MM/RRRR') RLSDATE, CF.CUSTODYCD, CI.ACCTNO AFACCTNO, CF.FULLNAME, SCHD.ACCTNO, AFT.ACTYPE, SY.VARVALUE BUSDATE,
        (SCHD.NML+SCHD.OVD+SCHD.PAID)  PRINPAID, SCHD.PAID,
        ROUND((SCHD.INTNMLACR + SCHD.INTDUE + SCHD.INTOVD + SCHD.INTOVDPRIN + SCHD.INTPAID),0) INTLN,
        ROUND(SCHD.INTPAID,0) INTPAID,
        (SCHD.NML+SCHD.OVD) DEBTLEFT ,
        CASE WHEN (SCHD.NML+SCHD.OVD) <> 0 THEN (TO_DATE(SY.VARVALUE,'DD/MM/RRRR') -
            TO_DATE(SCHD.RLSDATE,'DD/MM/RRRR') ) ELSE (TO_DATE(SCHD.OVDACRDATE,'DD/MM/RRRR') -
                TO_DATE(SCHD.RLSDATE,'DD/MM/RRRR') )  END DEALDAYS,
        nvl(reaflnk.re_name,' ') reman

    FROM (SELECT * FROM LNSCHD UNION ALL SELECT * FROM LNSCHDHIST) SCHD, LNMAST MST, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
         (SELECT  max(cf.fullname) re_name, afacctno, max(cf.custid) custid FROM reaflnk re, cfmast cf,retype retyp
            WHERE re.deltd = 'N' AND re.status = 'A' AND cf.custid = substr(reacctno,1,10)
            AND substr(reacctno,11,4)=retyp.actype
            AND retyp.rerole='CS'
            GROUP BY re.afacctno
         ) reaflnk,
        CIMAST CI, AFMAST AF, AFTYPE AFT, SYSVAR SY
    WHERE MST.ACCTNO = SCHD.ACCTNO
        AND AF.CUSTID = CF.CUSTID
        AND AF.ACTYPE = AFT.ACTYPE
        AND AF.ACCTNO = CI.ACCTNO
        AND SCHD.REFTYPE IN ('GP')
        AND CI.ACCTNO = MST.TRFACCTNO
        AND CF.CUSTID = CI.CUSTID
        AND af.CUSTID = reaflnk.afacctno(+)
        AND MST.FTYPE = 'AF'
        AND SY.VARNAME = 'CURRDATE'
        AND nvl(reaflnk.custid,' ') LIKE V_REID
        AND CF.CUSTODYCD LIKE V_STRI_CUSTODYCD
        AND AF.ACCTNO LIKE V_STRI_AFACCTNO
        AND AF.ACTYPE LIKE V_STRI_ACTYPE
        AND AF.CAREBY LIKE V_CAREBY
        AND (substr(af.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(af.custid,1,4))<> 0)
       -- and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        AND SCHD.RLSDATE BETWEEN V_FROMDATE AND V_TODATE
        )
        WHERE DEALDAYS>=v_dealdays
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
