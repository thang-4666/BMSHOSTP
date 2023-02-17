SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0101 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_SYMBOL                IN      varchar2
  )
IS
    CUR            PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
    v_custodycd    varchar2(20);
    v_symbol        varchar2(20);
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

    IF PV_SYMBOL = 'ALL' THEN
        v_symbol := '%%';
    ELSE
        v_symbol := PV_SYMBOL;
    END IF;

    OPEN PV_REFCURSOR FOR
        SELECT PV_CUSTODYCD ocustodycd, cf.fullname, cf.custodycd, br.brname, sb.symbol, cf.cfclsdate, se.trade, AL.cdcontent  PRODUCTTYPE
            FROM (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf,
             afmast af, cimast ci,brgrp br, semast se, sbsecurities sb, allcode al
        WHERE (cf.status in ( 'C','G') OR  af.status ='B')
            AND cf.custid = af.custid
            AND cf.custid = ci.custid
            AND af.acctno = se.afacctno
            AND cf.custodycd LIKE v_custodycd
            AND se.codeid = sb.codeid
            and af.PRODUCTTYPE = al.cdval
            and ci.afacctno = af.acctno
            and al.cdname='PRODUCTTYPE'
            and al.cdtype ='CF'
            AND sb.symbol LIKE v_symbol
            and sb.sectype <> '004'
            AND se.trade >= 1
            AND cf.brid = br.brid;
EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
 
 
 
/
