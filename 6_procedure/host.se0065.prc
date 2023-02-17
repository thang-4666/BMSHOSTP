SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0065" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_ISCOREBANK         IN       VARCHAR2,
   PV_BANKNAME         IN       VARCHAR2
)
IS
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);

   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_FROMDATE DATE;
   V_TODATE DATE;
   V_ISCOREBANK               VARCHAR2(20);
   V_STRBANKNAME               VARCHAR2(100);

   V_BANKNAME varchar2(100);



BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
   V_TODATE := to_date(T_DATE,'DD/MM/RRRR');

   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%';
   END IF;

   IF(PV_ISCOREBANK = 'ALL' OR PV_ISCOREBANK IS NULL)
    THEN
       V_ISCOREBANK := '%';
   ELSE
       V_ISCOREBANK := PV_ISCOREBANK;
   END IF;

   IF(PV_BANKNAME <> 'ALL')   THEN        V_STRBANKNAME  := PV_BANKNAME;
   ELSE        V_STRBANKNAME  := '%';
   END IF;

   IF (PV_BANKNAME <> 'ALL')
   THEN
        SELECT  CDCONTENT INTO V_BANKNAME FROM
        ALLCODE WHERE CDTYPE = 'CF' AND CDNAME = 'BANKNAME' AND CDVAL = PV_BANKNAME;
   ELSE
        V_BANKNAME := 'ALL';
   END IF;



-- GET REPORT'S DATA
    OPEN PV_REFCURSOR
    FOR
        SELECT tran.busdate, tran.acctno, tran.custodycd, cf.fullname,
           tran.namt ,
           V_BANKNAME bankname, PV_ISCOREBANK corebank,
             nvl(ser.taxamt,0) + nvl(ser.pitamt,0) TTNCN
        FROM vw_citran_gen tran,  (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, afmast af, seretail ser ,
        (select * from tllogfld where fldcd='06' union all select * from tllogfldall where fldcd='06') fld
        WHERE tran.tltxcd = '8894'AND tran.field = 'BALANCE' AND tran.txcd = '0029'-- AND tran.txcd IN ('0085','0011')--
            AND tran.custid = cf.custid
            AND tran.acctno = af.acctno
            AND tran.txnum  = fld.txnum
            AND TRAN.TXNUM=FLD.TXNUM
            AND ser.txdate=substr(fld.cvalue,1,10)
            and ser.txnum=substr(fld.cvalue,11)
            --AND tran.acctref = to_char(ser.txdate,'dd/mm/yyyy') || ser.txnum
            AND tran.custodycd LIKE V_CUSTODYCD
            AND tran.acctno LIKE V_STRAFACCTNO
            AND af.corebank LIKE V_ISCOREBANK
            AND af.bankname LIKE V_STRBANKNAME
            AND tran.busdate <= V_TODATE AND tran.busdate >= V_FROMDATE
            AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )


/*SELECT tran.busdate, tran.acctno, tran.custodycd, cf.fullname,
       tran.namt ,
       V_BANKNAME bankname, PV_ISCOREBANK corebank,
       round(tran.namt*sysvar.varvalue/100) TTNCN
FROM vw_citran_gen tran, cfmast cf, afmast af, sysvar
WHERE tran.tltxcd = '8894'AND tran.field = 'RECEIVING' -- AND tran.txcd IN ('0085','0011')--
AND tran.custid = cf.custid
AND sysvar.varname = 'ADVSELLDUTY'
AND tran.acctno = af.acctno
AND tran.custodycd LIKE V_CUSTODYCD
AND tran.acctno LIKE V_STRAFACCTNO
AND af.corebank LIKE V_ISCOREBANK
AND af.bankname LIKE V_STRBANKNAME
AND tran.busdate <= V_TODATE AND tran.busdate >= V_FROMDATE

UNION
SELECT tl.busdate, af.acctno, cf.custodycd, cf.fullname, tl.msgamt,
    V_BANKNAME bankname, PV_ISCOREBANK corebank,
    round(tl.msgamt*sysvar.varvalue/100) TTNCN
FROM vw_tllog_all tl, cfmast cf, afmast af, sysvar
WHERE cf.custid = af.custid AND tl.deltd <> 'Y' AND substr(tl.msgacct,1,10) = af.acctno
AND af.corebank = 'Y' AND tl.tltxcd = '8894'
AND sysvar.varname = 'ADVSELLDUTY'
AND cf.custodycd LIKE V_CUSTODYCD
AND af.acctno LIKE V_STRAFACCTNO
AND af.corebank LIKE V_ISCOREBANK
AND af.bankname LIKE V_STRBANKNAME
AND tl.busdate <= V_TODATE AND tl.busdate >= V_FROMDATE*/

;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
