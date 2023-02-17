SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0024 (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   TYPEDATE         IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   CUSTODYCD        IN       VARCHAR2,
   AFACCTNO         IN       VARCHAR2,
   TLTXCD           IN       VARCHAR2,
   SYMBOL           IN       VARCHAR2,
   AFTYPE           IN       VARCHAR2,
   BAL_TYPE           IN       VARCHAR2
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
-- DUNGNH   14-SEP-09  MODIFIED
-- ---------   ------  -------------------------------------------

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
    V_STRTLTXCD         VARCHAR (900);
    V_STRTLTXCD_1      VARCHAR (900);
    V_STRTLTXCD_2      VARCHAR (900);
    V_STRTLTXCD_3      VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCUSTODYCD          VARCHAR(20);
    V_STRAFACCTNO          VARCHAR(20);
    V_AFTYPE                VARCHAR(20);
    V_CMD           VARCHAR (2000);
    V_CMD_1           VARCHAR (2000);
    V_CMD_2           VARCHAR (2000);
    V_CMD_3           VARCHAR (2000);
    V_WHERE           VARCHAR (2000);
    V_WHERE_1           VARCHAR (2000);
    V_WHERE_2           VARCHAR (2000);
    V_WHERE_3           VARCHAR (2000);
    V_STRBALTYPE         VARCHAR(20);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
    V_STRBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(pv_BRID,1,2) || '__' ;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF(TYPEDATE <> 'ALL') THEN
        V_STRTYPEDATE := TYPEDATE;
   ELSE
        V_STRTYPEDATE := '003';
   END IF;

     IF  (AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := AFACCTNO;
   ELSE
         V_STRAFACCTNO := '%';
   END IF;

        IF  (CUSTODYCD <> 'ALL')
   THEN
         V_STRCUSTODYCD := CUSTODYCD;
   ELSE
         V_STRCUSTODYCD := '%';
   END IF;

   IF  (TLTXCD <> 'ALL')
   THEN
         V_STRTLTXCD := TLTXCD;
   ELSE
         V_STRTLTXCD := '%';
   END IF;

   IF  (SYMBOL <> 'ALL')
   THEN
         V_STRSYMBOL := SYMBOL;
   ELSE
         V_STRSYMBOL := '%';
   END IF;

      IF  (AFTYPE <> 'ALL')
   THEN
         V_AFTYPE := AFTYPE;
   ELSE
         V_AFTYPE := '%';
   END IF;

         IF  (BAL_TYPE <> 'ALL')
   THEN
         V_STRBALTYPE:= BAL_TYPE;
   ELSE
         V_STRBALTYPE := '%';
   END IF;

  -- GET REPORT'S DATA  DEVIDENTRATE

 IF V_STRTYPEDATE='002' THEN

 OPEN PV_REFCURSOR
 FOR

 --SE0024
SELECT SE.* FROM (

SELECT TLG.busdate,TLG.TXNUM, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'D' , TLG.NAMT, 0), DECODE(TLG.txtype, 'C' , TLG.NAMT, 0)) PS_TANG,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'C' , TLG.NAMT, 0), DECODE(TLG.txtype, 'D' , TLG.NAMT, 0)) PS_GIAM,
      (CASE WHEN TLG.tltxcd = '2248' AND TLG.field = 'BLOCKDTOCLOSE'  THEN 'HCCN'
          WHEN TLG.tltxcd = '2248'   AND TLG.field = 'DTOCLOSE'  THEN 'TU DO'
          WHEN TLG.tltxcd = '2266'   AND TLG.field = 'BLOCKWITHDRAW'  THEN 'HCCN'
          WHEN TLG.tltxcd = '2266'   AND TLG.field = 'WITHDRAW'  THEN 'TU DO'
          WHEN TLG.tltxcd in ('8867','8823','3350','3354')   AND TLG.field = 'MORTAGE'  THEN 'CC'
          WHEN TLG.field = 'BLOCKED'  THEN 'HCCN'
          ELSE 'TU DO'
       END) field,
      TLG.tltxcd, SB.parvalue
FROM vw_setran_gen TLG

LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid

WHERE  TLG.TLTXCD IN ('8867','8868','2246','2245','2266','3351','2248','8879','2201','2205','2202','2203','2204','2232','8823',
       '8817','8878','2234','3320','3350','3354','8901')
        AND TLG.deltd<>'Y'
      AND TLG.FIELD IN ('TRADE','MORTAGE','BLOCKED','STANDING','WITHDRAW','DTOCLOSE','BLOCKWITHDRAW','BLOCKDTOCLOSE','NETTING','EMKQTTY')


UNION ALL

SELECT TLG.busdate,TLG.TXNUM, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'D' , TLG.NAMT, 0), DECODE(TLG.txtype, 'C' , TLG.NAMT, 0)) PS_TANG,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'C' , TLG.NAMT, 0), DECODE(TLG.txtype, 'D' , TLG.NAMT, 0)) PS_GIAM,
      (CASE WHEN TLG.TLTXCD='2251' AND TLG.field = 'STANDING' THEN 'CC'
        WHEN TLG.TLTXCD='2253' AND TLG.field = 'STANDING' THEN 'CC'
        WHEN TLG.field = 'BLOCKED'  THEN 'HCCN'
          ELSE 'TU DO'
       END) field,
      TLG.tltxcd, SB.parvalue
FROM vw_setran_gen TLG

LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid

WHERE  TLG.TLTXCD IN ('2200','2220','2221','2244','2247','2251','2253','2254','2239','2242','2263','2262'
       ,'2287','2290','2293','3355','3356','8824','8828','8863','8866','2268','2209','2218')
        AND TLG.deltd<>'Y'
      AND TLG.FIELD IN('TRADE','BLOCKED','EMKQTTY','STANDING','NETTING')

) SE,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
WHERE SE.FIELD LIKE V_STRBALTYPE
      AND CF.CUSTODYCD=SE.CUSTODYCD
      AND SE.ACCTNO LIKE V_STRAFACCTNO
      AND SE.CUSTODYCD LIKE V_STRCUSTODYCD
      AND SE.SYMBOL LIKE V_STRSYMBOL
      AND SE.TLTXCD LIKE V_STRTLTXCD
      AND SUBSTR(SE.CUSTODYCD,4,1) LIKE  V_AFTYPE
      AND SE.BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
ORDER BY SE.BUSDATE,SE.TLTXCD, SE.CUSTODYCD, SE.ACCTNO ;

ELSE
   OPEN PV_REFCURSOR
 FOR

 --SE0024
SELECT SE.* FROM (

SELECT TLG.busdate,TLG.TXNUM, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'D' , TLG.NAMT, 0), DECODE(TLG.txtype, 'C' , TLG.NAMT, 0)) PS_TANG,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'C' , TLG.NAMT, 0), DECODE(TLG.txtype, 'D' , TLG.NAMT, 0)) PS_GIAM,
      (CASE WHEN TLG.tltxcd = '2248' AND TLG.field = 'BLOCKDTOCLOSE'  THEN 'HCCN'
          WHEN TLG.tltxcd = '2248'   AND TLG.field = 'DTOCLOSE'  THEN 'TU DO'
          WHEN TLG.tltxcd = '2266'   AND TLG.field = 'BLOCKWITHDRAW'  THEN 'HCCN'
          WHEN TLG.tltxcd = '2266'   AND TLG.field = 'WITHDRAW'  THEN 'TU DO'
          WHEN TLG.tltxcd in ('8867','8823','3350','3354')   AND TLG.field = 'MORTAGE'  THEN 'CC'
          WHEN TLG.field = 'BLOCKED'  THEN 'HCCN'
          ELSE 'TU DO'
       END) field,
      TLG.tltxcd, SB.parvalue
FROM vw_setran_gen TLG

LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid

WHERE  TLG.TLTXCD IN ('8867','8868','2246','2245','2266','3351','2248','8879','2201','2205','2202','2203','2204','2232',
       '8817','8878','2234','3320','3350','3354','8901')
      AND TLG.deltd<>'Y'
      AND TLG.FIELD IN ('TRADE','MORTAGE','BLOCKED','STANDING','WITHDRAW','DTOCLOSE','BLOCKWITHDRAW','BLOCKDTOCLOSE','NETTING','EMKQTTY')
      AND TLG.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')

UNION ALL

SELECT TLG.busdate,TLG.TXNUM, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'D' , TLG.NAMT, 0), DECODE(TLG.txtype, 'C' , TLG.NAMT, 0)) PS_TANG,
      DECODE(TLG.field, 'STANDING' , DECODE(TLG.txtype, 'C' , TLG.NAMT, 0), DECODE(TLG.txtype, 'D' , TLG.NAMT, 0)) PS_GIAM,
      (CASE WHEN TLG.TLTXCD='2251' AND TLG.field = 'STANDING' THEN 'CC'
        WHEN TLG.TLTXCD='2253' AND TLG.field = 'STANDING' THEN 'CC'
        WHEN TLG.field = 'BLOCKED'  THEN 'HCCN'
          ELSE 'TU DO'
       END) field,
      TLG.tltxcd, SB.parvalue
FROM vw_setran_gen TLG

LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid

WHERE  TLG.TLTXCD IN ('2200','2220','2221','2244','2247','2251','2253','2254','2239','2242','2263','2262'
       ,'2287','2290','2293','3355','3356','8866','2268','2218')
        AND TLG.deltd<>'Y'
      AND TLG.FIELD IN('TRADE','BLOCKED','EMKQTTY','STANDING','NETTING')
      AND TLG.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')

) SE,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
WHERE SE.FIELD LIKE V_STRBALTYPE
AND SE.CUSTODYCD=CF.CUSTODYCD
      AND SE.ACCTNO LIKE V_STRAFACCTNO
      AND SE.CUSTODYCD LIKE V_STRCUSTODYCD
      AND SE.SYMBOL LIKE V_STRSYMBOL
      AND SE.TLTXCD LIKE V_STRTLTXCD
      AND SUBSTR(SE.CUSTODYCD,4,1) LIKE  V_AFTYPE

ORDER BY SE.BUSDATE,SE.TLTXCD, SE.CUSTODYCD, SE.ACCTNO ;
END IF;

/*   V_CMD := 'SELECT TLG.busdate, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''D'', TLG.NAMT, 0), DECODE(TLG.txtype, ''C'', TLG.NAMT, 0)) PS_TANG,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''C'', TLG.NAMT, 0), DECODE(TLG.txtype, ''D'', TLG.NAMT, 0)) PS_GIAM,
            (CASE WHEN TLG.tltxcd = ''2248'' AND TLG.ref = ''002'' AND TLG.field = ''BLOCKED'' THEN ''HCCN''
                WHEN TLG.tltxcd = ''2248'' AND TLG.ref <> ''002'' AND TLG.field = ''BLOCKED'' THEN ''TU DO''
                WHEN TLG.tltxcd = ''2266'' AND TLG.ref = ''002'' AND TLG.field = ''WITHDRAW'' THEN ''HCCN''
                WHEN TLG.field = ''BLOCKED'' THEN ''HCCN''
                ELSE ''TU DO''
             END) field,
            TLG.tltxcd, SB.parvalue
        FROM vw_setran_gen TLG
        LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid';
   V_CMD_1 := 'SELECT TLG.busdate, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''D'', TLG.NAMT, 0), DECODE(TLG.txtype, ''C'', TLG.NAMT, 0)) PS_TANG,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''C'', TLG.NAMT, 0), DECODE(TLG.txtype, ''D'', TLG.NAMT, 0)) PS_GIAM,
            (CASE WHEN TLG.field = ''BLOCKED'' THEN ''HCCN''
                ELSE ''TU DO''
             END) field,
            TLG.tltxcd, SB.parvalue
        FROM vw_setran_gen TLG
        LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid';
   V_CMD_2 := 'SELECT TLG.busdate, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''D'', TLG.NAMT, 0), DECODE(TLG.txtype, ''C'', TLG.NAMT, 0)) PS_TANG,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''C'', TLG.NAMT, 0), DECODE(TLG.txtype, ''D'', TLG.NAMT, 0)) PS_GIAM,
            (CASE WHEN TLG.field = ''STANDING'' THEN ''CC''
                ELSE ''TU DO''
             END) field,
            TLG.tltxcd, SB.parvalue
        FROM vw_setran_gen TLG
        LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid';
   V_CMD_3 := 'SELECT TLG.busdate, TLG.custodycd, SUBSTR(TLG.acctno, 1, 10) acctno, TLG.symbol, TLG.txdesc,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''D'', TLG.NAMT, 0), DECODE(TLG.txtype, ''C'', TLG.NAMT, 0)) PS_TANG,
            DECODE(TLG.field, ''STANDING'', DECODE(TLG.txtype, ''C'', TLG.NAMT, 0), DECODE(TLG.txtype, ''D'', TLG.NAMT, 0)) PS_GIAM,
            (CASE WHEN TLG.field = ''BLOCKED'' THEN ''CC''
                ELSE ''TU DO''
             END) field,
            TLG.tltxcd, SB.parvalue
        FROM vw_setran_gen TLG
        LEFT OUTER JOIN sbsecurities SB ON Sb.codeid = TLG.codeid';
   V_WHERE := ' where  TLG.busdate >= TO_DATE (''' || F_DATE || '''  ,''DD/MM/YYYY'')
            AND TLG.busdate <= TO_DATE (''' || T_DATE  || ''',''DD/MM/YYYY'')
            AND substr(TLG.acctno,1, 4) LIKE ''' || V_STRBRID || '''';

   IF(CUSTODYCD <> 'ALL') THEN
        V_WHERE := V_WHERE || ' AND TLG.CUSTODYCD = ''' || CUSTODYCD || '''' ;
   END IF;

   IF(AFACCTNO <> 'ALL') THEN
        V_WHERE := V_WHERE || ' AND TLG.ACCTNO = ''' || AFACCTNO || '''' ;
   END IF;

   IF  (SYMBOL <> 'ALL') THEN
      V_WHERE := V_WHERE || ' AND TLG.SYMBOL = ''' || replace (trim(SYMBOL),' ','_') || '''' ;
   END IF;

   IF(AFTYPE <> 'ALL') THEN
        V_AFTYPE  := AFTYPE;
   ELSE
        V_AFTYPE  := 'C F P';
   END IF;

   V_WHERE := V_WHERE || ' AND INSTR(''' || V_AFTYPE || '''' || ', substr(TLG.custodycd, 4, 1)) > 0' ;
   V_WHERE_1 := V_WHERE;
   V_WHERE_2 := V_WHERE;
   V_WHERE_3 := V_WHERE;

   V_WHERE := V_WHERE || ' AND TLG.FIELD IN(''TRADE'',''MORTAGE'',''BLOCKED'',''NETTING'',''STANDING'',''WITHDRAW'',''DTOCLOSE'')' ;
   V_WHERE_1 := V_WHERE;
   V_WHERE_2 := V_WHERE_2 || ' AND TLG.FIELD IN(''BLOCKED'',''STANDING'')' ;
   V_WHERE_3 := V_WHERE_3 || ' AND TLG.FIELD IN(''BLOCKED'',''TRADE'')' ;

   IF BAL_TYPE = 'ALL' THEN
       IF (TLTXCD <> 'ALL') THEN
            if instr('8866 8868 2246 2245 2266 3351 2248 8879 2201 2205', tltxcd) > 0 then
               V_WHERE := V_WHERE || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT B.* FROM ( ' || V_CMD || V_WHERE || ') B, AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') ORDER BY B.busdate';
            elsif instr('2202 2203',tltxcd ) >0 then
               V_WHERE_1 := V_WHERE_1 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               V_WHERE_1 := V_WHERE_1 || ' AND TLG.REF = ''002''';
               OPEN PV_REFCURSOR FOR 'SELECT B.* FROM ( ' || V_CMD_1 || V_WHERE_1 || ') B, AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'')  ORDER BY B.busdate';
            elsif instr('2251',tltxcd ) >0 then
               V_WHERE_2 := V_WHERE_2 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT B.* FROM ( ' || V_CMD_2 || V_WHERE_2 || ') B, AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'')  ORDER BY B.busdate';
            elsif instr('2253',tltxcd ) >0 then
               V_WHERE_3 := V_WHERE_3 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT B.* FROM ( ' || V_CMD_3 || V_WHERE_3 || ') B, AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'')  ORDER BY B.busdate';
            end if;
       ELSE
            V_STRTLTXCD := '8866 8868 2246 2245 2266 3351 2248 8879 2201 2205';
            V_STRTLTXCD_1:= '2202 2203';
            V_STRTLTXCD_2:= '2251';
            V_STRTLTXCD_3:= '2253';

           V_WHERE := V_WHERE || ' AND INSTR(''' || V_STRTLTXCD || '''' || ', TLG.TLTXCD) > 0' ;
           V_WHERE_1 := V_WHERE_1 || ' AND INSTR(''' || V_STRTLTXCD_1 || '''' || ', TLG.TLTXCD) > 0' || ' AND TLG.REF = ''002''';
           V_WHERE_2 := V_WHERE_2 || ' AND INSTR(''' || V_STRTLTXCD_2 || '''' || ', TLG.TLTXCD) > 0' ;
           V_WHERE_3 := V_WHERE_3 || ' AND INSTR(''' || V_STRTLTXCD_3 || '''' || ', TLG.TLTXCD) > 0' ;

           OPEN PV_REFCURSOR FOR 'SELECT B.* FROM ( ' || V_CMD || V_WHERE
                || ' UNION ALL ' || V_CMD_1 || V_WHERE_1
                || ' UNION ALL ' || V_CMD_2 || V_WHERE_2
                || ' UNION ALL ' || V_CMD_3 || V_WHERE_3 || ') B, AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'')  ORDER BY B.busdate';
       END IF;
   ELSE
       IF (TLTXCD <> 'ALL')
       THEN
            if instr('8866 8868 2246 2245 2266 3351 2248 8879 2201 2205', tltxcd) > 0 then
               V_WHERE := V_WHERE || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT C.* FROM (SELECT B.* FROM ( ' || V_CMD || V_WHERE || ') B ) C,
                    AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') AND C.field = ''' || BAL_TYPE || ''' ORDER BY C.busdate';
            elsif instr('2202 2203',tltxcd ) >0 then
               V_WHERE_1 := V_WHERE_1 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               V_WHERE_1 := V_WHERE_1 || ' AND TLG.REF = ''002''';
               OPEN PV_REFCURSOR FOR 'SELECT C.* FROM (SELECT B.* FROM ( ' || V_CMD_1 || V_WHERE_1 || ') B ) C
                    ,AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') AND C.field = ''' || BAL_TYPE || ''' ORDER BY C.busdate';
            elsif instr('2251',tltxcd ) >0 then
               V_WHERE_2 := V_WHERE_2 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT C.* FROM (SELECT B.* FROM ( ' || V_CMD_2 || V_WHERE_2 || ') B ) C
                     ,AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') AND C.field = ''' || BAL_TYPE || ''' ORDER BY C.busdate';
            elsif instr('2253',tltxcd ) >0 then
               V_WHERE_3 := V_WHERE_3 || ' AND TLG.TLTXCD = ''' || TLTXCD || '''' ;
               OPEN PV_REFCURSOR FOR 'SELECT C.* FROM (SELECT B.* FROM ( ' || V_CMD_3 || V_WHERE_3 || ') B ) C
                     ,AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') AND C.field = ''' || BAL_TYPE || ''' ORDER BY C.busdate';
            end if;
       ELSE
            V_STRTLTXCD := '8866 8868 2246 2245 2266 3351 2248 8879 2201 2205';
            V_STRTLTXCD_1:= '2202 2203';
            V_STRTLTXCD_2:= '2251';
            V_STRTLTXCD_3:= '2253';

           V_WHERE := V_WHERE || ' AND INSTR(''' || V_STRTLTXCD || '''' || ', TLG.TLTXCD) > 0' ;
           V_WHERE_1 := V_WHERE_1 || ' AND INSTR(''' || V_STRTLTXCD_1 || '''' || ', TLG.TLTXCD) > 0' || ' AND TLG.REF = ''002''';
           V_WHERE_2 := V_WHERE_2 || ' AND INSTR(''' || V_STRTLTXCD_2 || '''' || ', TLG.TLTXCD) > 0' ;
           V_WHERE_3 := V_WHERE_3 || ' AND INSTR(''' || V_STRTLTXCD_3 || '''' || ', TLG.TLTXCD) > 0' ;

           OPEN PV_REFCURSOR FOR 'SELECT C.* FROM (SELECT B.* FROM ( ' || V_CMD || V_WHERE
                || ' UNION ALL ' || V_CMD_1 || V_WHERE_1
                || ' UNION ALL ' || V_CMD_2 || V_WHERE_2
                || ' UNION ALL ' || V_CMD_3 || V_WHERE_3 || ') B ) C
                     ,AFMAST A WHERE A.ACCTNO = B.ACCTNO AND A.ACTYPE NOT IN (''0000'') AND C.field = ''' || BAL_TYPE || ''' ORDER BY C.busdate';
       END IF;
   END IF;
   */

EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
/
