SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BO1003" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   BONDTYPE     IN       VARCHAR2
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
   V_BONDTYPE       VARCHAR2(5);

BEGIN

   V_STROPTION := OPT;

  IF V_STROPTION = 'A' then
      V_STRBRID := '%';
  ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(pv_brid,1,2) || '__' ;
  else
      V_STRBRID:=pv_BRID;
  END IF;

 -- GET REPORT'S PARAMETERS
    V_IDATE := TO_DATE(I_DATE,'DD/MM/RRRR');
    if (UPPER(PV_CUSTODYCD) = 'ALL' OR PV_CUSTODYCD IS NULL) THEN
        V_STRCUSTODYCD := '%';
    ELSE
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    END IF;


    if BONDTYPE = 'ALL' THEN
        V_BONDTYPE:='%';
    ELSE
        V_BONDTYPE:=BONDTYPE;
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
        cf.custodycd, cf.fullname, iss.fullname issfullname, sb.intcoupon, A1.CDCONTENT SECCONTENT,
        sb.symbol, a0.CDCONTENT BONDTYPE, sb.expdate,
        CASE WHEN sb.expdate < V_IDATE THEN 0 ELSE round(nvl((sb.expdate-V_IDATE)/360 ,0),2) END CONLAI,
        se.acctno, se.trade-nvl(tr.se_trade_move_amt,0) trade
    from semast se, sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, issuers iss,
        ALLCODE A0,ALLCODE A1,
        (
            select tr.acctno, sum(case when tr.txtype = 'D' then -tr.namt else tr.namt end) se_trade_move_amt
            from vw_setran_gen tr
            where TR.deltd <> 'Y'
                and tr.txdate > V_IDATE
                and tr.field in ('TRADE')
            group by tr.acctno
        ) tr
    where se.codeid = sb.codeid
        AND SB.issuerid = ISS.issuerid
        and sb.bondtype <> '000'
        and se.afacctno = af.acctno
        and cf.custid = af.custid
        and a0.CDTYPE = 'SA' AND a0.CDNAME = 'BONDTYPE' AND a0.CDUSER = 'Y'
        and a1.CDTYPE = 'SA' AND a1.CDNAME = 'SECTYPE' AND a1.CDUSER = 'Y'
        AND SB.SECTYPE = A1.CDVAL
        and sb.bondtype = a0.cdval
        and sb.bondtype like V_BONDTYPE
        and se.trade-nvl(tr.se_trade_move_amt,0) <> 0
        and cf.custodycd like V_STRCUSTODYCD
        and se.acctno = tr.acctno(+)
    ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
