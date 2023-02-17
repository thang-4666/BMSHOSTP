SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1038 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   I_BRIDGD                 IN       VARCHAR2
  )
IS
    CUR            PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
    v_custodycd    varchar2(20);
    v_fullname     varchar2(25);
    v_brid          varchar2(20);
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


    IF I_BRIDGD = 'ALL' THEN
        v_brid := '%%';
    ELSE
        v_brid := I_BRIDGD;
    END IF;
    OPEN PV_REFCURSOR FOR
        SELECT cf.fullname, cf.custodycd, br.brname, cf.cfclsdate, ci.balance, a.cdcontent PRODUCTTYPE
        FROM (SELECT  * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 ) cf,
        afmast  af,
        cimast   ci,brgrp br,allcode a
        WHERE cf.custid = af.custid
        AND cf.custid = ci.custid
        AND cf.custodycd LIKE v_custodycd
        AND (cf.status IN( 'C','G')  OR  af.status ='B' )
        AND cf.brid LIKE v_brid
        AND cf.brid = br.brid
        and af.PRODUCTTYPE = a.cdval
        and a.cdname='PRODUCTTYPE'
        and a.cdtype ='CF'
        and ci.acctno = af.acctno
        and ci.balance >= 1
        order by cf.custodycd,a.lstodr;





EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;




-- End of DDL Script for Procedure HOSTDEV.CF1038
 
 
 
 
/
