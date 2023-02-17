SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE1018" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2
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

    V_STRTLTXCD         VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (5);
    v_strIBRID     VARCHAR2 (4);
    vn_BRID        varchar2(50);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS


 V_STROPT := upper(OPT);
    V_INBRID := BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(BRID,1,2) || '__' ;
        else
            V_STRBRID := BRID;
        end if;
    end if;

 OPEN PV_REFCURSOR
  FOR

SELECT  CASE WHEN SUBSTR(CF.custodycd,4,1)= 'P' THEN 'N01211' WHEN SUBSTR(CF.custodycd,4,1)= 'F' THEN 'N01213' ELSE 'N01212' END SHTK, 'N0121' TYP, 'N012' TYPETVTN,
  SUM( (se.trade + se.netting + se.withdraw +  se.mortage +se.standing +se.dtoclose+ nvl(semastdtl.qtty_TG_blocked,0)  -  nvl(dk_DTOCLOSE.se_DTOCLOSE_dk,0)
      - nvl(dtl.se_GD_move_amt,0)  - nvl(dtl.se_BLOCKED_move_TG,0)+ nvl(dtl.se_DTOCLOSE_HCCN_move_amt,0) - nvl(WITHDRAW_HCCN.WITHDRAW_HCCN,0) - nvl(dtl.se_WITHDRAW_move_amt,0)  )* sb.parvalue ) se_DK, SUM (nvl(PS.se_GD_PS_CR,0)* sb.parvalue ) se_PS_CR, SUM (nvl(PS.se_GD_PS_DR,0)* sb.parvalue ) se_PS_DR
 FROM semast se, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,sbsecurities sb,
      (
       select se.acctno, se.blocked qtty_hccn_dtoclose , se.emkqtty qtty_TG_blocked
    from semast se, sbsecurities sb
    where se.codeid = sb.codeid
        and sb.sectype <> '004'
       ) SEMASTDTL,
   (select tr.acctno,  sum( case when field = 'DTOCLOSE' and tr.ref = '002'  then
                         (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_dk
    from vw_setran_gen tr
    where tr.sectype <> '004'
    AND TR.deltd <> 'Y'
    and tr.field ='DTOCLOSE'
     group by tr.acctno)dk_DTOCLOSE,
 (select sum(blocked+ sblocked) WITHDRAW_HCCN,acctno
 from sesendout where deltd <>'Y' group by acctno
having sum(blocked+ sblocked) >0) WITHDRAW_HCCN,
(select tr.acctno,
        sum
        (
          case when field in ( 'TRADE','NETTING','MORTAGE' ,'STANDING','DTOCLOSE') then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end
        ) se_GD_move_amt,            -- Phat sinh CK giao dich
        sum
        ( case when field = 'BLOCKED' and nvl(tr.ref,' ') <> '002' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0   end
         ) se_BLOCKED_move_TG,      -- Phat sinh CK tam giu
         sum
        ( case when field = 'BLOCKED' and tr.ref = '002'   then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_BLOCKED_move_HCCN,      -- Phat sinh CK HCNN
          sum
        ( case when field = 'DTOCLOSE' and   tr.ref <>'002'  then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt,
        sum
        ( case when field = 'DTOCLOSE' and tr.ref ='002'  then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_HCCN_move_amt
         ,
        sum
        ( case when field = 'WITHDRAW' AND NVL(TR.REF,'-')<> '002' then
                (case when tr.txtype = 'D'  then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
        sum
        ( case when field = 'WITHDRAW' AND TR.REF ='002' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt_HCCN         -- Phat sinh CK cho nhan ve


  from vw_setran_gen tr
  where tr.sectype <> '004'
    AND TR.deltd <> 'Y'
    and tr.busdate   >=  to_date(F_DATE,'DD/MM/YYYY')
    and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','WITHDRAW','DTOCLOSE')
     group by tr.acctno)DTL,
     --PS
     (
     select tr.acctno,

          sum
        (
          case when (field in ( 'TRADE','NETTING','WITHDRAW','MORTAGE','STANDING' ) and  tr.txtype = 'D')
                   OR  ( field = 'BLOCKED' AND nvl(tr.ref,' ') <> '002'   AND   tr.txtype = 'D')
                  OR  ( field = 'DTOCLOSE' AND NVL(Tr.ref,' ')  <>'002'   AND   tr.txtype = 'D')
          then tr.namt else 0  end
        ) se_GD_PS_DR ,          -- Phat sinh CK giao dich
          sum
        (
          case when (field in ( 'TRADE','NETTING','WITHDRAW','MORTAGE','STANDING' ) and  tr.txtype = 'C')
                   OR  ( field = 'BLOCKED' AND nvl(tr.ref,' ') <> '002'   AND   tr.txtype = 'C')
                    OR  ( field = 'DTOCLOSE'  AND NVL(tr.ref ,' ') <>'002'   AND   tr.txtype = 'C')
          then tr.namt else 0  end
        ) se_GD_PS_CR           -- Phat sinh CK giao dich

 from vw_setran_gen tr
 where tr.sectype <> '004'
 AND TR.TLTXCD NOT IN ('8867','2262','2263','2264','3356','2247','2242','2673','2661','2652','2290','2649','2646','2200','2244','8878','2254')
 AND (CASE WHEN  TR.TLTXCD IN ('2202','2203') AND  nvl(tr.ref,' ') <> '002' THEN 1 ELSE 0 END  ) = 0
  AND (CASE WHEN  TR.TLTXCD IN ('2266') AND  nvl(tr.ref,' ') ='002' THEN 1 ELSE 0 END  ) = 0
  and tr.busdate > = to_date(F_DATE,'DD/MM/YYYY')
 and tr.busdate < = to_date(T_DATE,'DD/MM/YYYY')
 AND TR.deltd <> 'Y'
 AND TR.FIELD IN ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','DTOCLOSE','WITHDRAW')
 GROUP BY TR.ACCTNO
    )PS
 WHERE   se.afacctno = af.acctno and af.custid= cf.custid

and se.acctno = SEMASTDTL.acctno (+)
and se.acctno = DTL.acctno (+)
and se.acctno = PS.acctno (+)
and se.acctno = dk_DTOCLOSE.acctno (+)
and se.acctno = WITHDRAW_HCCN.acctno (+)
and sb.codeid = se.codeid
AND CF.custatcom ='Y'
and sb.sectype<>'004'
and cf.brid like V_STRBRID
GROUP BY SUBSTR(CF.custodycd,4,1)

UNION

SELECT  CASE WHEN SUBSTR(CF.custodycd,4,1)= 'P' THEN 'N01221' WHEN SUBSTR(CF.custodycd,4,1)= 'F' THEN 'N01223' ELSE 'N01222' END SHTK, 'N0122' TYP, 'N012' TYPETVTN,
  SUM( nvl( semastdtl.qtty_hccn,0)* sb.parvalue + nvl(dk_DTOCLOSE.se_DTOCLOSE_dk,0)* sb.parvalue - nvl(dtl.se_BLOCKED_move_HCCN,0)* sb.parvalue - nvl(dtl.se_DTOCLOSE_HCCN_move_amt,0)* sb.parvalue
  + nvl(WITHDRAW_HCCN.WITHDRAW_HCCN,0)* sb.parvalue - nvl(dtl.se_WITHDRAW_move_amt_HCCN,0)* sb.parvalue

   ) se_DK, SUM (nvl(PS.se_PS_CR,0)* sb.parvalue) se_PS_CR, SUM (nvl(PS.se_PS_DR* sb.parvalue,0)) se_GD_PS_DR
  FROM semast se, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,sbsecurities sb,
      (
        select se.acctno, se.blocked qtty_hccn
        from semast se, sbsecurities sb
        where se.codeid = sb.codeid
            and sb.sectype <> '004'
       ) SEMASTDTL,
   (select sum(blocked+ sblocked) WITHDRAW_HCCN,acctno
   from sesendout where deltd <>'Y' group by acctno
   having sum(blocked+ sblocked) >0) WITHDRAW_HCCN,
  (select tr.acctno,  sum( case when field = 'DTOCLOSE' and tr.ref = '002'  then
                         (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_dk
    from vw_setran_gen tr
    where tr.sectype <> '004'
    AND TR.deltd <> 'Y'
    and tr.field ='DTOCLOSE'
     group by tr.acctno)dk_DTOCLOSE,
(select tr.acctno,
         sum
        ( case when field = 'BLOCKED' and tr.ref = '002'   then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_BLOCKED_move_HCCN ,     -- Phat sinh CK HCNN
            sum
        ( case when field = 'DTOCLOSE' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_DTOCLOSE_move_amt,
        sum
        ( case when field = 'DTOCLOSE' and tr.ref = '002'  then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end

        ) se_DTOCLOSE_HCCN_move_amt,
         sum
        ( case when field = 'WITHDRAW' AND NVL(TR.REF,'-')<> '002' then
                (case when tr.txtype = 'D'  then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
        sum
        ( case when field = 'WITHDRAW' AND TR.REF ='002' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0
            end
        ) se_WITHDRAW_move_amt_HCCN         -- Phat sinh CK cho nhan ve

    from vw_setran_gen tr
    where tr.sectype <> '004'
    AND TR.deltd <> 'Y'
    and tr.busdate   >=  to_date(F_DATE,'DD/MM/YYYY')
    and tr.field IN ('BLOCKED','DTOCLOSE','WITHDRAW')
     group by tr.acctno)DTL,
     --PS
     (
     select tr.acctno,
        sum
        (
          case when   ( field = 'BLOCKED' AND nvl(tr.ref,' ') = '002'   AND   tr.txtype = 'D')
           OR   ( field = 'DTOCLOSE' AND  nvl(tr.ref,' ') ='002'    AND   tr.txtype = 'D')
           OR   ( field = 'WITHDRAW' AND  nvl(tr.ref,' ') ='002'    AND   tr.txtype = 'D')
          then tr.namt else 0  end
        ) se_PS_DR ,          -- Phat sinh CK giao dich
          sum
        (
          case when  ( field = 'BLOCKED' AND nvl(tr.ref,' ') = '002'   AND   tr.txtype = 'C')
           OR   ( field = 'DTOCLOSE' AND nvl(tr.ref,' ') ='002'  AND   tr.txtype = 'C')
           OR   ( field = 'WITHDRAW' AND  nvl(tr.ref,' ') ='002'    AND   tr.txtype = 'C')
          then tr.namt else 0  end
        ) se_PS_CR           -- Phat sinh CK giao dich
 from vw_setran_gen tr
 where tr.sectype <> '004'
 AND TR.deltd <> 'Y'
 and tr.tltxcd not in ('2247','2244','8878','2254')
      and tr.busdate > = to_date(F_DATE,'DD/MM/YYYY')
     and tr.busdate < = to_date(T_DATE,'DD/MM/YYYY')
 AND TR.FIELD IN ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','DTOCLOSE','WITHDRAW')
 GROUP BY TR.ACCTNO

     )PS
 WHERE   se.afacctno = af.acctno and af.custid= cf.custid
and se.acctno = SEMASTDTL.acctno (+)
and se.acctno = DTL.acctno (+)
and se.acctno = PS.acctno (+)
and se.acctno = dk_DTOCLOSE.acctno (+)
and se.acctno = WITHDRAW_HCCN.acctno (+)
AND CF.custatcom ='Y'
and sb.sectype<>'004'
and sb.codeid = se.codeid
and cf.brid like V_STRBRID
GROUP BY SUBSTR(CF.custodycd,4,1)

UNION

SELECT  CASE WHEN SUBSTR(CF.custodycd,4,1)= 'P' THEN 'N01231' WHEN SUBSTR(CF.custodycd,4,1)= 'F' THEN 'N01233' ELSE 'N01232' END SHTK, 'N0123' TYP, 'N012' TYPETVTN,
  SUM( - nvl( SE.standing,0) * sb.parvalue + nvl(dtl.se_STANDING_move,0)* sb.parvalue ) se_DK, SUM (nvl(PS.se_PS_CR,0)* sb.parvalue) se_PS_CR, SUM (nvl(PS.se_PS_DR,0)* sb.parvalue) se_GD_PS_DR
  FROM semast se, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,sbsecurities sb  ,
/*      (SELECT acctno, se.blocked qtty_hccn, sum(case when qttytype<>'002' then qtty else 0 end)   qtty_tg
       FROM semastdtl
       WHERE DELTD <>'Y' and status ='N' group by acctno
       ) SEMASTDTL,*/
(select tr.acctno,
         sum
        ( case when field = 'STANDING' then
                (case when tr.txtype = 'D' then -tr.namt else tr.namt end)
            else 0 end
         ) se_STANDING_move      -- Phat sinh CK HCNN
    from vw_setran_gen tr
    where tr.sectype <> '004'
   and tr.busdate   >=  to_date(F_DATE,'DD/MM/YYYY')
   AND TR.deltd <> 'Y'
     -- and tr.busdate > v_OnDate and tr.busdate <= v_CurrDate
    and tr.field ='STANDING'
     group by tr.acctno)DTL,
     --PS
     (     select tr.acctno,
        sum
        (
          case when   ( field = 'STANDING'   AND   tr.txtype = 'C')
          then tr.namt else 0  end
        ) se_PS_DR ,          -- Phat sinh CK giao dich
          sum
        (
          case when  ( field = 'STANDING'   AND   tr.txtype = 'D')
          then tr.namt else 0  end
        ) se_PS_CR           -- Phat sinh CK giao dich
 from vw_setran_gen tr
 where tr.sectype <> '004'
 AND TR.deltd <> 'Y'
    and tr.busdate > = to_date(F_DATE,'DD/MM/YYYY')
     and tr.busdate < = to_date(T_DATE,'DD/MM/YYYY')
 AND TR.FIELD ='STANDING'
 GROUP BY TR.ACCTNO

     )PS
 WHERE   se.afacctno = af.acctno and af.custid= cf.custid
---and se.acctno = SEMASTDTL.acctno (+)
and se.acctno = DTL.acctno (+)
and se.acctno = PS.acctno (+)
AND CF.custatcom ='Y'
and sb.sectype<>'004'
and sb.codeid = se.codeid
and cf.brid like V_STRBRID
GROUP BY SUBSTR(CF.custodycd,4,1);


EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
 
 
 
/
