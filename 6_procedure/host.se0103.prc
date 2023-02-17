SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0103 (
                               PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
                               OPT                      IN       VARCHAR2,
                               PV_BRID                  IN       VARCHAR2,
                               TLGOUPS                  IN       VARCHAR2,
                               TLSCOPE                  IN       VARCHAR2,
                               F_DATE                   IN       VARCHAR2,
                               T_DATE                   IN       VARCHAR2,
                               PV_CUSTODYCD             IN       VARCHAR2,
                               PV_IBRID                 IN       VARCHAR2,
                               PV_REACCTNO              IN       varchar2,
                                PV_ACTYPE                 IN       VARCHAR2,
                               PV_UD              IN       varchar2
  )
IS
    CUR            PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
    v_custodycd    varchar2(20);
    v_ibrid         varchar2(20);
    v_reacctno      varchar2(20);
     v_PV_ACTYPE         varchar2(20);
    v_PV_UD      varchar2(20);
BEGIN
    V_STROPTION := OPT;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(PV_BRID,1,2) || '__' ;
    ELSE
        V_STRBRID:=PV_BRID;
    END IF;

    IF PV_CUSTODYCD = 'ALL' THEN
        v_custodycd := '%%';
    ELSE
        v_custodycd := PV_CUSTODYCD;
    END IF;

    IF PV_IBRID = 'ALL' THEN
        v_ibrid := '%%';
    ELSE
        v_ibrid := PV_IBRID;
    END IF;

    IF PV_REACCTNO = 'ALL' THEN
        v_reacctno := '%%';
    ELSE
        v_reacctno := PV_REACCTNO;
    END IF;
  IF PV_ACTYPE = 'ALL' THEN
        v_PV_ACTYPE := '%%';
    ELSE
        v_PV_ACTYPE := PV_ACTYPE;
    END IF;

     IF PV_UD = 'ALL' THEN
        v_PV_UD := '%%';
    ELSE
        v_PV_UD := PV_UD;
    END IF;
    OPEN PV_REFCURSOR FOR
        SELECT max(cf.fullname) fullname, (cf.custodycd) custodycd, nvl(fee.typename,nvl(to_char(rese.feeamt,'0.9'), ' ')) CS_UUDAI, max(nvl(cft.typename, ' ')) HANG_KH,
           max( rese.acctno) acctno, rese.reacctno, sum(rese.amt) PHI_VCBS, sum(rese.qtty) qtty,
            round(sum(rese.qtty * rese.vsdfeeamt * rese.days/30), 4) PHI_VSD, to_char(rese.txdate,'MM') MM
        FROM (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, afmast af,cftype cft,
            (select afacctno, max(actype)actype from cifeedef_extlnk  group by afacctno  ) lnk,
             cifeedef_ext fee,
            (SELECT se.autoid, (se.acctno) acctno, substr((se.acctno), 1, 10) afacctno, (qtty) qtty, (amt) amt, (feeamt) feeamt, (vsdfeeamt) vsdfeeamt,
                (txdate) txdate, (days) days,
                (se.reacctno) reacctno
             FROM sedepobal se
            WHERE  se.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
                AND se.txdate <= to_date(T_DATE, 'DD/MM/RRRR')
               -- and feeamt <>vsdfeeamt
            )rese
        WHERE af.acctno = rese.afacctno
            AND af.custid = cf.custid
            and cf.actype = cft.actype
            and rese.afacctno= lnk.afacctno(+)
            and lnk.actype = fee.actype(+)
            AND cf.brid LIKE v_ibrid
            AND cf.custodycd LIKE v_custodycd
            and cft.actype like v_PV_ACTYPE
            AND NVL( lnk.actype,'-') LIKE v_PV_UD
        GROUP BY rese.reacctno, cf.custodycd,to_char(rese.txdate,'MM'),rese.feeamt,fee.typename;
EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
 
 
 
/
