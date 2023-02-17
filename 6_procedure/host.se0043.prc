SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0043" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS

-- ---------   ------  -------------------------------------------

   V_CUSTODYCD VARCHAR2 (15);
   V_FROMDATE DATE;
   V_TODATE DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION    VARCHAR2(5);

BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

    V_CUSTODYCD := upper( PV_CUSTODYCD);

     V_FROMDATE := TO_DATE(F_DATE, 'DD/MM/RRRR');
     V_TODATE := TO_DATE(T_DATE, 'DD/MM/RRRR');


-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT DISTINCT SE.TXNUM,SE.TXTIME,CF.BRID,SE.TXDATE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,CF.IDCODE, CF.IDDATE, CF.IDPLACE,SE.symbol,
       (CASE WHEN SE.TXCD='0011' THEN 'TRADE' ELSE 'BLOCK' END) FIELD,SE.namt,FLD.NVALUE
FROM VW_SETRAN_GEN SE,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
     (
      select txnum, txdate, fldcd, nvalue from tllogfldall
        where fldcd = '11'
         union all
          select txnum, txdate, fldcd, nvalue from tllogfld
          where fldcd = '11'
           )fld,
            (
             select txnum, txdate, fldcd, cvalue from tllogfldall
               where fldcd = '31'
                 union all
                    select txnum, txdate, fldcd, cvalue from tllogfld
                     where fldcd = '31'

           )fld1
WHERE CF.CUSTID=SE.CUSTID
      AND SE.TLTXCD='2244'
      AND SE.TXCD IN ('0011','0044')
      AND SE.txnum=FLD.TXNUM
      AND SE.TXDATE=FLD.TXDATE
      AND SE.TXNUM=FLD1.TXNUM
      AND SE.TXDATE=FLD1.TXDATE
      AND FLD1.CVALUE='003'
      AND CF.CUSTODYCD LIKE V_CUSTODYCD
      AND SE.TXDATE BETWEEN V_FROMDATE AND V_TODATE
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
