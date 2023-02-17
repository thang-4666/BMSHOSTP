SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0056" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   CHECKER        IN       VARCHAR2
 )
IS
--

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);

   V_MAKER        varchar2(200);
   V_CKECKER       varchar2(200);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

         if(upper(PV_CUSTODYCD) <> 'ALL' OR  PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL)then

     V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    else
         V_STRCUSTODYCD := '%';
    end if;

         if(upper(MAKER) <> 'ALL' OR  MAKER <> '' OR MAKER <> NULL)then

     V_MAKER := UPPER(MAKER);
    else
         V_MAKER := '%';
    end if;

         if(upper(CHECKER) <> 'ALL' OR  CHECKER <> '' OR CHECKER <> NULL)then

     V_CKECKER := UPPER(CHECKER);
    else
         V_CKECKER := '%';
    end if;

         if(upper(I_BRID) <> 'ALL' OR  I_BRID <> '' OR I_BRID <> NULL)then

     V_I_BRIDGD := UPPER(I_BRID);
    else
         V_I_BRIDGD := '%';
    end if;


    if(upper(I_BRID) <> 'ALL' OR  I_BRID <> '' OR I_BRID <> NULL)
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRID;
      END;
   ELSE
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;


   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR

SELECT CF.CUSTID,CF.CUSTODYCD,CF.FULLNAME, BR.BRNAME, MAIN.MAKER_DT,NVL(CF.MOBILESMS,'') MOBILESMS,
       NVL(MAIN.FROM_VALUE,'') TELE_OLD,MAIN.TO_VALUE TELE_NEW ,
       NVL(TLP.TLNAME,'') MAKER , NVL(TLP1.TLNAME,'') CHECKER
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, MAINTAIN_LOG MAIN,BRGRP BR,TLPROFILES TLP1,TLPROFILES TLP
WHERE MAIN.TABLE_NAME='CFMAST'
      AND MAIN.ACTION_FLAG='EDIT'
      AND CF.CUSTID=SUBSTR(TRIM(MAIN.RECORD_KEY),11,10)
      AND MAIN.COLUMN_NAME='MOBILESMS'
      AND BR.BRID=CF.BRID
      AND MAIN.APPROVE_ID=TLP1.TLID(+)
      AND MAIN.MAKER_ID= TLP.TLID(+)
      AND (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
      AND CF.BRID LIKE V_I_BRIDGD
      AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
      AND NVL(MAIN.MAKER_ID,'') LIKE V_MAKER
      AND NVL(MAIN.APPROVE_ID,'') LIKE V_CKECKER
      AND MAIN.MAKER_DT BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
ORDER BY MAIN.MAKER_DT,CF.CUSTODYCD
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
