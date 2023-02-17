SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI1019" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   COREBANK         IN       VARCHAR2,
   BANKNAME         IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   CHECKER        IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2
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
-- NAMNT   11-APR-2012  MODIFIED
-- ---------   ------  -------------------------------------------

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (5);
    v_strIBRID     VARCHAR2 (4);
    vn_BRID        varchar2(50);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
    V_STRBANKNAME       VARCHAR(20);

   V_BRNAME     VARCHAR2 (1000);
   V_I_BRIDGD     VARCHAR2 (20);

   V_MAKER       VARCHAR2(100);
   V_CHECKER     VARCHAR2(100);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS


 V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(pv_BRID,1,2) || '__' ;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;




   IF(COREBANK <> 'ALL')
   THEN
        V_STRCOREBANK  := COREBANK;
   ELSE
        V_STRCOREBANK  := '%%';
   END IF;

    IF(PV_CUSTODYCD <> 'ALL')
   THEN
        V_STRPV_CUSTODYCD  := PV_CUSTODYCD;
   ELSE
        V_STRPV_CUSTODYCD  := '%%';
   END IF;

    IF(PV_AFACCTNO <> 'ALL')
   THEN
        V_STRPV_AFACCTNO  := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%%';
   END IF;

    IF(BANKNAME <> 'ALL')
   THEN
        V_STRBANKNAME  := BANKNAME;
   ELSE
        V_STRBANKNAME := '%%';
   END IF;

      -----------------------
     IF  (MAKER <> 'ALL')
   THEN
         V_MAKER := MAKER;
   ELSE
         V_MAKER := '%';
   END IF;

        IF  (CHECKER <> 'ALL')
   THEN
         V_CHECKER := CHECKER;
   ELSE
         V_CHECKER := '%';
   END IF;
   -----------------------
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

 OPEN PV_REFCURSOR
  FOR

SELECT TL.BUSDATE,CF.CUSTODYCD,AF.ACCTNO,CF.FULLNAME,sum(TL.NAMT) NAMT,
       CF.BRID,TL.TXDESC,A0.CDCONTENT PRODUC, TLP.TLNAME MAKER, TLP1.TLNAME CHECKER
FROM VW_CITRAN_GEN TL, AFMAST AF, AFTYPE AFT, ALLCODE A0,TLPROFILES TLP, TLPROFILES TLP1,
(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
WHERE TL.ACCTNO=AF.ACCTNO
AND TL.DELTD<>'Y'
AND TL.TXCD='0012'
AND TL.TLTXCD='1137'
AND AF.CUSTID=CF.CUSTID
AND AF.ACTYPE=AFT.ACTYPE
AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
AND TL.TLID=TLP.TLID(+)
AND NVL(TL.OFFID,'0000')=TLP1.TLID(+)
AND TL.TLID LIKE V_MAKER
AND NVL(TL.OFFID,'0000') LIKE V_CHECKER
AND CF.BRID LIKE V_I_BRIDGD
AND AF.COREBANK LIKE V_STRCOREBANK
AND TL.BUSDATE BETWEEN  TO_date(F_DATE,'DD/MM/YYYY') AND TO_date(T_DATE,'DD/MM/YYYY')
AND AF.BANKNAME LIKE V_STRBANKNAME
AND CF.CUSTODYCD LIKE V_STRPV_CUSTODYCD
AND AF.ACCTNO LIKE V_STRPV_AFACCTNO
GROUP BY TL.BUSDATE,CF.CUSTODYCD,AF.ACCTNO,CF.FULLNAME,CF.BRID,TL.TXDESC,A0.CDCONTENT, TLP.TLNAME, TLP1.TLNAME
ORDER BY BUSDATE, CUSTODYCD

;


EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure

 
 
 
 
/
