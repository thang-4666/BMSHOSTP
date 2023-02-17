SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0034" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_CIACCTNO    IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   CHECKER        IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   TLID           IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO TINH PHI LUU KY CHO TUNG TAI KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUYETKD    29-05-2011  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2  (5);
   V_STRBRID       VARCHAR2  (4);
   V_STRCUSTODYCD   VARCHAR2 (20);
   STR_CIACCTNO      VARCHAR2(20);
   V_STRTLID           VARCHAR2(6);
    V_STRMAKER       VARCHAR2(20);
   V_STRCHECKER     VARCHAR2(20);


   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
BEGIN
   V_STRTLID:= TLID;
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
  IF (CUSTODYCD <> 'ALL' or CUSTODYCD <> '')
   THEN
      V_STRCUSTODYCD :=  CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;


 IF (PV_CIACCTNO <> 'ALL' or PV_CIACCTNO <> '')
   THEN
      STR_CIACCTNO :=  PV_CIACCTNO;
   ELSE
      STR_CIACCTNO := '%%';
   END IF;

     if(upper(MAKER) = 'ALL' OR LENGTH(MAKER) < 1 )then
        V_STRMAKER := '%';
    else
        V_STRMAKER := UPPER(MAKER);
    end if;

    if(upper(CHECKER) = 'ALL' OR LENGTH(CHECKER) < 1 )then
        V_STRCHECKER := '%';
    else
        V_STRCHECKER := UPPER(CHECKER);
    end if;

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
   -- GET REPORT'S DATA

   OPEN PV_REFCURSOR
       FOR
   SELECT V_STRCUSTODYCD CUST_1,STR_CIACCTNO CIACCTNO,
         cf.custodycd, cf.fullname,CF.BRID, af.acctno, A0.CDCONTENT PRODUC,cit.*
   FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,AFTYPE AFT, ALLCODE A0,

        (     SELECT ci.acctno, CI.TXDATE,NVL(CI.txdesc,TL.txdesc) TXDESC,TLP.TLNAME MAKER, TLP1.TLNAME CHECKER,
                     sum(case when ci.txtype='C' then ci.NAMT else 0 end) PT,
                     sum(case when ci.txtype='D' then ci.NAMT else 0 end) GT
              FROM vw_citran_gen ci, TLTX TL, TLPROFILES TLP, TLPROFILES TLP1
              WHERE ci.field in ('EMKAMT')
                    AND CI.TLTXCD=TL.TLTXCD
                    AND ci.deltd = 'N'
                    AND CI.TLID=TLP.TLID(+)
                    AND NVL(CI.offid,'000')=TLP1.TLID(+)
                    AND CI.TLID LIKE V_STRMAKER
                    AND NVL(CI.offid,'000') LIKE V_STRCHECKER
                    and ci.txdate >= to_date(F_DATE,'dd/mm/rrrr')
                    and ci.txdate <= to_date(T_DATE,'dd/mm/rrrr')
              group by ci.acctno,CI.TXDATE,NVL(CI.txdesc,TL.txdesc),TLP1.TLNAME,TLP.TLNAME
         ) cit
    WHERE cf.custid = af.custid
          and af.acctno = cit.acctno
          AND AF.ACTYPE=AFT.ACTYPE
          AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
          AND CF.BRID LIKE V_I_BRIDGD
          and af.acctno like STR_CIACCTNO
          and cf.custodycd like V_STRCUSTODYCD
    ORDER BY TXDATE, CUSTODYCD,AF.ACCTNO;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
