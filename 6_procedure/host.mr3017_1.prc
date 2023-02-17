SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3017_1"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,

     pv_aftype IN      VARCHAR2,
          pv_BRGID  IN VARCHAR2

   ) IS
----------------------
--bao cao trang thai tai khoan tai VCBS
--ngocvtt 24/05/2015
   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(5);
   V_STRCUSTODYCD   VARCHAR2(20);
   V_STRAFACCTNO    VARCHAR2(20);
         v_FRDATE DATE;
     v_TODATE DATE;
     v_aftype VARCHAR2(4);
     v_recustid VARCHAR2(10);
     v_currdate DATE;
          v_BRGID VARCHAR2(4);

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

     IF pv_aftype <> 'ALL' THEN v_aftype := pv_aftype;
     ELSE v_aftype:= '%%';
     END IF;

          IF pv_BRGID <> 'ALL' THEN v_BRGID:= pv_BRGID;
         ELSE v_BRGID:= '%%';
         END IF;


     v_FRDATE:= to_date(F_DATE,'DD/MM/RRRR');
     v_TODATE:= to_date(T_DATE,'DD/MM/RRRR');
     select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR
SELECT A.*, a0.cdcontent aftypename, br.brname FROM(
          SELECT  INDATE, fullname,custodycd,acctno, marginrate,marginamt,t0amt,marginovdamt,
                  margininamt , t0ovdamt,totalvnd,careby, seass,NVL(MRCRLIMIT,0)MRCRLIMIT ,NVL(AVLLIMIT_MG,0) AVLLIMIT_MG,NVL(AVLLIMIT,0) AVLLIMIT
          FROM TBL_VMR0001
          UNION ALL
          SELECT  v_CurrDate INDATE, v.fullname,v.custodycd,v.acctno, v.marginrate,v.marginamt,v.t0amt,v.marginovdamt,
                  v.margininamt , v.t0ovdamt,v.totalvnd,v.careby, v.seass,V.mrcrlimitmax MRCRLIMIT,AVLLIMIT_MG,AVLLIMIT
          FROM VW_MR0001 v
        ) A,
        CFMAST CF,
        afmast af, aftype aft, brgrp br, allcode a0
WHERE CF.CUSTODYCD=A.CUSTODYCD
        AND CF.BRID = br.brid
        AND a.acctno = af.acctno AND af.actype = aft.actype
        AND aft.producttype LIKE v_aftype
        AND br.brid LIKE v_BRGID
        AND A.INDATE BETWEEN v_FRDATE AND v_todate
        AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        AND A.CUSTODYCD LIKE V_STRCUSTODYCD
        AND A.ACCTNO LIKE   V_STRAFACCTNO
        ORDER BY A.INDATE,A.CUSTODYCD,A.ACCTNO

 ;


EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure
 
 
 
 
/
