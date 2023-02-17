SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1088_1 (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   TLTXCD           IN       VARCHAR2,
   MAKER            IN       VARCHAR2,
   CHECKER          IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   TLID            IN       VARCHAR2,
   PV_CLASS         IN       VARCHAR2,
   PV_PACCOUNT         IN       VARCHAR2
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

    V_STROPTION     VARCHAR2 (10);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

    V_STRTLTXCD         VARCHAR (900);
    V_STRSYMBOL         VARCHAR (20);
    V_STRTYPEDATE       VARCHAR(5);
    V_STRCHECKER        VARCHAR(20);
    V_STRMAKER          VARCHAR(20);
    V_STRCOREBANK          VARCHAR(20);
    V_STROPT       VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (20);
    v_strIBRID     VARCHAR2 (20);
    V_STRPV_CUSTODYCD   varchar2(50);
    V_STRPV_AFACCTNO   varchar2(50);
    V_STRTLID           VARCHAR2(10);
    v_STRALTERNATEACCT varchar2(10);
    v_time          number;
    v_currdate      date;
    v_strclass      varchar2(100);
    v_paccount      varchar2(100);

    V_SYSNAME     VARCHAR2(20);
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STRTLID:= TLID;

 V_STROPT := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
          --  V_STRBRID := substr(BRID,1,2) || '__' ;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;


    select TO_DATE(VARVALUE,'DD/MM/RRRR') INTO v_currdate from sysvar where varname = 'CURRDATE';

   IF(TLTXCD <> 'ALL')
   THEN
        V_STRTLTXCD := TLTXCD||'%';
      ELSE
        V_STRTLTXCD := '%%';
   END IF;

   IF(CHECKER <> 'ALL')
   THEN
        V_STRCHECKER := CHECKER;
   ELSE
        V_STRCHECKER := '%%';
   END IF;

   IF(MAKER <> 'ALL')
   THEN
        V_STRMAKER  := MAKER;
   ELSE
        V_STRMAKER  := '%%';
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

    IF (pv_CLASS = 'ALL')
    THEN
         v_strCLASS := '%';
    ELSE
         v_strCLASS := CASE WHEN PV_CLASS='Y' THEN '000' ELSE '001' END  ;
    END IF;

      IF PV_PACCOUNT = 'N' THEN
 OPEN PV_REFCURSOR
              FOR
        SELECT ci.CUSTID, cf.careby, ci.tltxcd   tltxcd ,tltx.txdesc ,ci.txnum,ci.busdate ,ci.txdate,ci.acctno,ci.custodycd,
        '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,
        nvl(ck.tlname,'')  ck,nvl(tp.tradename, br.brname) brid,nvl(ci.tlid,'') tlid,nvl(ci.OFFID,'') OFFID,
                ''bankid,ci.corebank ,'' bankname,nvl(CI.trdesc, ci.txdesc )ci_txdesc,
                round(CASE WHEN CI.TXTYPE ='D' THEN NAMT  ELSE 0 END)  DR,
                round(CASE WHEN CI.TXTYPE ='C' THEN NAMT  ELSE 0 END)  CR,
                tp.tradename, ci_from.balance BeginAMT
        FROM  tlprofiles mk,tlprofiles ck, tradeplace tp, tradecareby tc,
                 vw_citran_gen   ci,tltx , cfmast cf, brgrp br,
                 (
                    select sum(round(ci.balance) - nvl(ci_from_todate.amt,0)) balance
                    from cimast ci, cfmast cf,
                    (
                        select ci.acctno,sum(decode(CI.TXTYPE,'D',round(-NAMT),round(NAMT))) AMT
                        from vw_citran_gen ci, cfmast cf
                        where ci.custid=cf.custid
                            and ci.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                            and ci.field IN ('BALANCE','NETTING')
                            and ci.field || ci.txtype not like 'NETTING' || 'C'
                            and ci.tltxcd not like '8865'
                            and cf.class like v_strclass
                            and ci.custodycd not like systemnums.C_DEALINGCD||'%'
                            and ci.custodycd not like 'OTC%'
                            AND ci.custodycd LIKE V_STRPV_CUSTODYCD
                            AND ci.acctno LIKE V_STRPV_AFACCTNO
                        group by ci.acctno
                    ) ci_from_todate
                    where ci.custid = cf.custid
                        and ci.acctno = ci_from_todate.acctno (+)
                        and cf.class like v_strclass
                        and cf.custodycd not like systemnums.C_DEALINGCD||'%'
                        and cf.custodycd not like 'OTC%'
                        AND cf.custodycd LIKE V_STRPV_CUSTODYCD
                        AND ci.acctno LIKE V_STRPV_AFACCTNO

                 ) ci_from
        where ci.custid=cf.custid
                AND cf.careby = tc.grpid(+)
                AND tc.tradeid = tp.traid(+)
                and cf.brid = br.brid
                and ci.tltxcd = tltx.tltxcd
                and ci.tlid = mk.tlid(+)
                and ci.OFFID =ck.tlid(+)
                and ci.field IN ('BALANCE','NETTING')
                and ci.field || ci.txtype not like 'NETTING' || 'C'
                and ci.tltxcd not like '8865'
                and ci.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and ci.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                and cf.class like v_strclass
                and cf.custodycd not like systemnums.C_DEALINGCD||'%'
                and cf.custodycd not like 'OTC%'
                AND ci.TLTXCD LIKE V_STRTLTXCD
                AND NVL( ci.TLID,'-') LIKE V_STRMAKER
                AND NVL( ci.OFFID,'-') LIKE V_STRCHECKER
                AND ci.custodycd LIKE V_STRPV_CUSTODYCD
                AND ci.acctno LIKE V_STRPV_AFACCTNO
        ORDER BY CI.TXDATE,CI.TLTXCD ,CI.TXNUM;
      ELSE
 OPEN PV_REFCURSOR
              FOR
        SELECT ci.CUSTID, cf.careby, ci.tltxcd   tltxcd ,tltx.txdesc ,ci.txnum,ci.busdate ,ci.txdate,ci.acctno,ci.custodycd, '' custodycdc,'' acctnoc,ci.namt amt,nvl(mk.tlname,'') mk,
        nvl(ck.tlname,'')  ck,nvl(tp.tradename, br.brname) brid,nvl(ci.tlid,'') tlid,nvl(ci.OFFID,'') OFFID,
                ''bankid,ci.corebank ,'' bankname,nvl(CI.trdesc, ci.txdesc )ci_txdesc,
                round(CASE WHEN CI.TXTYPE ='D' THEN NAMT  ELSE 0 END)  DR,
                round(CASE WHEN CI.TXTYPE ='C' THEN NAMT  ELSE 0 END)  CR,
                tp.tradename, ci_from.balance BeginAMT
        FROM  tlprofiles mk,tlprofiles ck, tradeplace tp, tradecareby tc,
                 vw_citran_gen   ci,tltx , cfmast cf, brgrp br,
                 (
                    select sum(round(ci.balance) - nvl(ci_from_todate.amt,0)) balance
                    from cimast ci, cfmast cf,
                    (
                        select ci.acctno,sum(decode(CI.TXTYPE,'D',round(-NAMT),round(NAMT))) AMT
                        from vw_citran_gen ci, cfmast cf
                        where ci.custid=cf.custid
                            and ci.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                            and ci.field IN ('BALANCE','NETTING')
                            and ci.field || ci.txtype not like 'NETTING' || 'C'
                            and ci.tltxcd not like '8865'
                            and cf.class like v_strclass
                            and ci.custodycd not like systemnums.C_DEALINGCD||'%'
                            and ci.custodycd not like 'OTC%'
                            AND ci.custodycd LIKE V_STRPV_CUSTODYCD
                            AND ci.acctno LIKE V_STRPV_AFACCTNO
                        group by ci.acctno
                    ) ci_from_todate
                    where ci.custid = cf.custid
                        and ci.acctno = ci_from_todate.acctno (+)
                        and cf.class like v_strclass
                        and cf.custodycd not like 'OTC%'
                        AND cf.custodycd LIKE V_STRPV_CUSTODYCD
                        AND ci.acctno LIKE V_STRPV_AFACCTNO

                 ) ci_from
        where ci.custid=cf.custid
                AND cf.careby = tc.grpid(+)
                AND tc.tradeid = tp.traid(+)
                and cf.brid = br.brid
                and ci.tltxcd = tltx.tltxcd
                and ci.tlid = mk.tlid(+)
                and ci.OFFID =ck.tlid(+)
                and ci.field IN ('BALANCE','NETTING')
                and ci.field || ci.txtype not like 'NETTING' || 'C'
                and ci.tltxcd not like '8865'
                and ci.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
                and ci.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
                and cf.class like v_strclass
                and cf.custodycd not like 'OTC%'
                AND ci.TLTXCD LIKE V_STRTLTXCD
                AND NVL( ci.TLID,'-') LIKE V_STRMAKER
                AND NVL( ci.OFFID,'-') LIKE V_STRCHECKER
                AND ci.custodycd LIKE V_STRPV_CUSTODYCD
                AND ci.acctno LIKE V_STRPV_AFACCTNO
        ORDER BY CI.TXDATE,CI.TLTXCD ,CI.TXNUM;
        END IF;
EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
/
