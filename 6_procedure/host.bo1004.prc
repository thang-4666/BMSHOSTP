SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BO1004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- DANH SACH NGUOI SO HUU CHUNG KHOAN  LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0

   V_IDATE            DATE;
   V_STRCUSTODYCD     VARCHAR2(20);

BEGIN

   V_STROPTION := OPT;

  IF V_STROPTION = 'A' then
      V_STRBRID := '%';
  ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(BRID,1,2) || '__' ;
  else
      V_STRBRID:=BRID;
  END IF;

 -- GET REPORT'S PARAMETERS
    V_IDATE := TO_DATE(I_DATE,'DD/MM/RRRR');
    if (UPPER(PV_CUSTODYCD) = 'ALL' OR PV_CUSTODYCD IS NULL) THEN
        V_STRCUSTODYCD := '%';
    ELSE
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    END IF;
 -- END OF GETTING REPORT'S PARAMETERS

  -- GET REPORT'S DATA

OPEN PV_REFCURSOR
     FOR
    select V_IDATE indate,
        CASE WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 274 THEN '1'  --DUOI 1 NAM
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 274
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 548 THEN '2' -- TREN 1 DUOI 2
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 548
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 1278 THEN '3' -- TREN 2 DUOI 3
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 1278
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 1643 THEN '4' -- TREN 3 DUOI 4
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 1643
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 2008 THEN '5' -- TREN 4 DUOI 5
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 2008
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 2741 THEN '6' -- TREN 5 DUOI 7
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 2741
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 4016 THEN '7' -- TREN 7 DUOI 10
                ELSE '8' END KYHAN,
        cf.fullname, cf.custodycd, sum(se.trade-nvl(tr.se_trade_move_amt,0)) trade
    from semast se, sbsecurities sb, cfmast cf, afmast af,
        ALLCODE A0,
        (
            select tr.acctno, sum(case when tr.txtype = 'D' then -tr.namt else tr.namt end) se_trade_move_amt
            from vw_setran_gen tr
            where TR.deltd <> 'Y'
                and tr.txdate > V_IDATE
                and tr.field in ('TRADE')
            group by tr.acctno
        ) tr
    where se.codeid = sb.codeid
        and sb.bondtype <> '000'
        and se.afacctno = af.acctno
        and cf.custid = af.custid
        and a0.CDTYPE = 'SA' AND a0.CDNAME = 'BONDTYPE' AND a0.CDUSER = 'Y'
        and sb.bondtype = a0.cdval
        and se.trade-nvl(tr.se_trade_move_amt,0) <> 0
        and se.acctno = tr.acctno(+)
        and cf.custodycd like V_STRCUSTODYCD
    group by CASE WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 274 THEN '1'  --DUOI 1 NAM
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 274
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 548 THEN '2' -- TREN 1 DUOI 2
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 548
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 1278 THEN '3' -- TREN 2 DUOI 3
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 1278
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 1643 THEN '4' -- TREN 3 DUOI 4
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 1643
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 2008 THEN '5' -- TREN 4 DUOI 5
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 2008
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 2741 THEN '6' -- TREN 5 DUOI 7
                WHEN nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) >= 2741
                    AND nvl(TO_NUMBER(sb.expdate-sb.issuedate),0) < 4016 THEN '7' -- TREN 7 DUOI 10
                ELSE '8' END, cf.fullname, cf.custodycd
    ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
