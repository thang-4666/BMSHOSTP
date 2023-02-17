SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0041"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   MAKER      IN       VARCHAR2,
   CHECKER     IN       VARCHAR2,
   PV_CUSTODYCD    IN    VARCHAR2,
   LOAI     IN VARCHAR2

   ) IS


   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(5);
   V_STRCUSTODYCD  VARCHAR2(100);


   V_F_DATE         date;
   V_T_DATE         date;



   V_STRMAKER       VARCHAR2(20);
   V_STRCHECKER     VARCHAR2(20);
   V_STRLOAI  VARCHAR2(20);


   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

BEGIN


/*    V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;*/

      V_STROPT := OPT;

   IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
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


    v_F_date := to_date(F_DATE,'dd/mm/rrrr');
    v_T_date := to_date(T_DATE,'dd/mm/rrrr');

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

 if(upper(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1 )then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    end if;

   IF(LOAI <> 'ALL')
   THEN
        V_STRLOAI  := LOAI;
   ELSE
        V_STRLOAI  := '%%';
   END IF;
     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR

 SELECT DISTINCT MA.ACTION_FLAG,CF.FULLNAME, CF.CUSTID,CF.CUSTODYCD, 'CFMAST' ID,TL1.TLNAME MAKER, MA.MAKER_DT,
        TL2.TLNAME APP, FLD.CAPTION , MA.FROM_VALUE, MA.TO_VALUE,MA.COLUMN_NAME, BR.BRNAME
  FROM MAINTAIN_LOG MA, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, V_INBRID, TLGOUPS)=0) CF, TLPROFILES TL1, TLPROFILES TL2, BRGRP  BR,FLDMASTER FLD
  WHERE CF.BRID=BR.BRID
    AND  ma.table_name='CFMAST'
    and ma.action_flag='EDIT'
    and cf.custid=substr(trim(ma.record_key),11,10)
    AND MA.COLUMN_NAME IN ('FULLNAME','IDCODE','IDDATE','ADDRESS','EMAIL','TRADINGCODE','TRADINGOCDEDT')
    and tl1.tlid(+)=ma.maker_id
    and tl2.tlid(+)=ma.approve_id
    AND FLD.fldname = ma.column_name
    AND FLD.objname ='CF.CFMAST'
    AND  MA.MAKER_DT <= v_T_date
    AND  MA.MAKER_DT >= v_F_date
    AND MA.COLUMN_NAME LIKE V_STRLOAI
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND NVL(MA.MAKER_ID,'0001') LIKE V_STRMAKER
    AND NVL(MA.approve_id,'0001') LIKE V_STRCHECKER
    AND  ( substr(CF.CUSTID,1,4) like V_STRBRID or INSTR(V_STRBRID,CF.CUSTID) <> 0)
    AND substr(CF.custid,1,4) LIKE V_I_BRIDGD

ORDER BY CF.CUSTID,  MA.MAKER_DT
         ;


EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure

 
 
 
 
/
