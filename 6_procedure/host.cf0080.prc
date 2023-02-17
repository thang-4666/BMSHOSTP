SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0080" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   PV_TXKEY         IN       VARCHAR2
)
IS

    V_BRID              VARCHAR2(4);
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
    V_IDATE DATE;
    V_CUSTODYCD varchar2(20);
    v_COUNT  number;
    V_STRAFACCTNO VARCHAR2(10);

    V_BALANCE       number;

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
   v_COUNT :=0;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   V_CUSTODYCD := upper(replace(PV_CUSTODYCD,'.',''));




   IF(UPPER(PV_AFACCTNO) = 'ALL') THEN
        V_STRAFACCTNO := '%';
        select sum(balance) into V_BALANCE
        from
        (
        select MAX(balance) balance, afacctno
        from CF0080_LOG tl where TO_CHAR(TL.TXDATE,'DDMMRRRR') || TL.TXNUM = PV_TXKEY
            AND TL.CUSTODYCD = V_CUSTODYCD
            group by afacctno
            ) ;
   ELSE
        V_STRAFACCTNO := PV_AFACCTNO;
        select MAX(balance) into V_BALANCE
           from CF0080_LOG tl where TO_CHAR(TL.TXDATE,'DDMMRRRR') || TL.TXNUM = PV_TXKEY
           AND TL.CUSTODYCD = V_CUSTODYCD AND TL.afacctno = V_STRAFACCTNO;
   END IF;

OPEN PV_REFCURSOR FOR

        SELECT UPPER(PV_AFACCTNO) STRAFACCTNO, TL.BRID, TL.TXDATE, TL.FULLNAME, TL.IDCODE, to_char(TL.IDDATE,'DD/MM/RRRR') IDDATE, TL.IDPLACE,
            TL.ADDRESS, TL.CUSTODYCD, TL.SYMBOL, TL.TRADEPLACE, max(TL.TRADE) TRADE,
            max(TL.BLOCKED) BLOCKED, max(TL.TRADE_WFT) TRADE_WFT, max(TL.BLOCKED_WFT) BLOCKED_WFT,
            max(nvl(dep.fullname,'')) depositfullname,
            max(CASE WHEN TLFL.FLDCD = '47' THEN TLFL.cvalue ELSE '' END) RCVCUSTODYCD,
            max(CASE WHEN TLFL.FLDCD = '50' THEN TLFL.cvalue ELSE '' END) RCVCAFACCTNO,
            max(V_BALANCE) balance
        FROM CF0080_LOG TL, vw_tllogfld_all TLFL, deposit_member dep
        WHERE TL.CUSTODYCD like  V_CUSTODYCD AND TL.afacctno LIKE V_STRAFACCTNO
            AND TL.txdate = TLFL.TXDATE AND TL.txnum = TLFL.TXNUM
            AND TLFL.FLDCD IN ('48','47','50')
            AND FNC_VALIDATE_SCOPE(TL.BRID, '', TLSCOPE, PV_BRID, TLGOUPS)=0
            and (CASE WHEN TLFL.FLDCD = '48' THEN TLFL.cvalue ELSE '' END) = dep.depositid (+)
            AND TO_CHAR(TL.TXDATE,'DDMMRRRR') || TL.TXNUM = PV_TXKEY
        GROUP BY TL.BRID, TL.TXDATE, TL.FULLNAME, TL.IDCODE, TL.IDDATE, TL.IDPLACE, TL.ADDRESS,
            TL.CUSTODYCD, TL.SYMBOL, TL.TRADEPLACE
        ORDER BY SYMBOL
     ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
