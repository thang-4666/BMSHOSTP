SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0069 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   DATE_T         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2,
   PV_BRID        IN       VARCHAR2
   )

IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH  KHACH HANG CUA TOAN CONG TY
-- PERSON      DATE    COMMENTS
-- QUOCTA   28/04/2011  CREATED
-----------------------------------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (40);
   V_INBRID           VARCHAR2  (4);

   V_TRADEPLACE        VARCHAR2  (20);
   V_SECTYPE           VARCHAR2  (100);
   V_CASHPLACE         VARCHAR2  (100);

   TRAN_DATE           DATE;

   V_PV_STRBRID          VARCHAR2 (50);
   V_P_STRBRID          VARCHAR2 (10);
BEGIN
----- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   --ngoc.vu-Jira561
   IF (TRADEPLACE <> 'ALL' OR TRADEPLACE <> '')
   THEN
      V_TRADEPLACE :=  TRADEPLACE;
      TRAN_DATE :=  getduedate(TO_DATE(I_DATE, 'DD/MM/RRRR'), 'B', TRADEPLACE, TO_NUMBER(DATE_T));
   ELSE
      V_TRADEPLACE := '%';
      TRAN_DATE :=  getduedate(TO_DATE(I_DATE, 'DD/MM/RRRR'), 'B', '001', TO_NUMBER(DATE_T));
   END IF;

   IF (PV_SECTYPE <> 'ALL' OR PV_SECTYPE <> '')
   THEN
      V_SECTYPE :=  PV_SECTYPE;
   ELSE
      V_SECTYPE := '%';
   END IF;

   IF (CASHPLACE <> 'ALL' OR CASHPLACE <> '')
   THEN
      V_CASHPLACE :=  CASHPLACE;
   ELSE
      V_CASHPLACE := '%';
   END IF;



   if(upper(PV_BRID) = 'ALL' OR LENGTH(PV_BRID) <= 1) then
        V_pV_STRBRID := '%';
        V_P_STRBRID := '%';
    else
        if(upper(PV_BRID) = 'GROUP1') then
            V_pV_STRBRID := ' 0002,0001,0003 ';
            V_P_STRBRID := 'D';
        ELSE IF (upper(PV_BRID) = 'GROUP2') THEN
            V_pV_STRBRID := ' 0101,0102,0103 ';
            V_P_STRBRID := 'D';
        else
            V_pV_STRBRID := 'D';
            V_P_STRBRID := PV_BRID;
        end if;
        end if;
    end if;

----- GET REPORT'S DATA
 IF (CASHPLACE = 'ALL') THEN

 OPEN PV_REFCURSOR
 FOR
 SELECT (case
          when OD.TRADEPLACE='002' then '1. HNX'
          when OD.TRADEPLACE='001' then '2. HOSE'
          when OD.TRADEPLACE='005' then '3. UPCOM' else '' end) san,
          IOD.symbol symbol,
          iod.custodycd custodycd,
          iod.txtime txdate,
          iod.matchprice matchprice,
          decode(iod.bors,'B',iod.matchqtty,0) sl_buy,
          decode(iod.bors,'B',iod.matchqtty * iod.matchprice ,0) GT_buy,
          decode(iod.bors,'S',iod.matchqtty,0) sl_SELL,
          decode(iod.bors,'S',iod.matchqtty * iod.matchprice ,0) GT_SELL,
          TO_NUMBER(DATE_T) DATET, TRAN_DATE TRAN_DATE
FROM
(
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IOD where deltd <>'Y'
union all
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IODHIST where deltd <>'Y'
)IOD,
(
Select orderid,exectype,clearday,txdate, AFACCTNO,TRADEPLACE from vw_odmast_tradeplace_all where deltd <>'Y'
)OD,
/*(Select orgorderid ,bors,txdate from ood
union all
Select orgorderid ,bors,txdate from oodhist
) ood,*/
sbsecurities sb,
AFMAST AF, AFTYPE AFT, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where IOD.orgorderid= OD.orderid
--and IOD.txdate= OD.txdate
--and ood.orgorderid = IOD.orgorderid
--and ood.txdate= OD.txdate
and iod.symbol like  '%'
and od.exectype like '%'
and iod.custodycd like '%'
and sb.codeid=iod.codeid
and od.clearday = TO_NUMBER(DATE_T)
and od.txdate = TO_DATE(I_DATE, 'dd/mm/yyyy')
and (case when V_TRADEPLACE = '999' and OD.TRADEPLACE IN ('001','002') then '999'
                    else OD.TRADEPLACE end) like V_TRADEPLACE
---- AND OD.TRADEPLACE LIKE V_TRADEPLACE
AND OD.TRADEPLACE IN ('001','002','005')
AND SB.SECTYPE    LIKE V_SECTYPE
AND SB.SECTYPE    IN ('001','006','008','011') --Ngay 23/03/2017 CW NamTv them sectype 011
AND OD.AFACCTNO   = AF.ACCTNO
AND AF.ACTYPE     = AFT.ACTYPE
and af.custid = cf.custid
and cf.custatcom = 'Y'
---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
AND (CF.brid like V_p_STRBRID or instr(V_pV_STRBRID,CF.brid) <> 0 )
and (CF.brid like V_STRBRID or INSTR(V_STRBRID,CF.brid) <> 0)
AND AFT.COREBANK  LIKE '%'
AND AF.BANKNAME   LIKE '%'
 ;

 ELSIF (CASHPLACE = '000') THEN
 OPEN PV_REFCURSOR
 FOR
 SELECT (case
          when OD.TRADEPLACE='002' then '1. HNX'
          when OD.TRADEPLACE='001' then '2. HOSE'
          when OD.TRADEPLACE='005' then '3. UPCOM' else '' end) san,
          IOD.symbol symbol,
          iod.custodycd custodycd,
          iod.txtime txdate,
          iod.matchprice matchprice,
          decode(iod.bors,'B',iod.matchqtty,0) sl_buy,
          decode(iod.bors,'B',iod.matchqtty * iod.matchprice ,0) GT_buy,
          decode(iod.bors,'S',iod.matchqtty,0) sl_SELL,
          decode(iod.bors,'S',iod.matchqtty * iod.matchprice ,0) GT_SELL,
          TO_NUMBER(DATE_T) DATET, TRAN_DATE TRAN_DATE
FROM
(
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IOD where deltd <>'Y'
union all
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IODHIST where deltd <>'Y'
)IOD,
(
Select orderid,exectype,clearday,txdate, AFACCTNO,TRADEPLACE from vw_odmast_tradeplace_all where deltd <>'Y')OD,
/*(Select orgorderid ,bors,txdate from ood
union all
Select orgorderid ,bors,txdate from oodhist
) ood,*/
sbsecurities sb, AFMAST AF, AFTYPE AFT, cfmast cf
where IOD.orgorderid= OD.orderid
---and IOD.txdate= OD.txdate
---and ood.orgorderid = IOD.orgorderid
---and ood.txdate= OD.txdate
and sb.codeid=iod.codeid
and iod.symbol like  '%'
and od.exectype like '%'
and iod.custodycd like '%'
and od.clearday = TO_NUMBER(DATE_T)
and od.txdate = TO_DATE(I_DATE, 'dd/mm/yyyy')
and (case when V_TRADEPLACE = '999' and OD.TRADEPLACE IN ('001','002') then '999'
                    else OD.TRADEPLACE end) like V_TRADEPLACE
------AND OD.TRADEPLACE LIKE V_TRADEPLACE
AND OD.TRADEPLACE IN ('001','002','005')
---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND SB.SECTYPE    LIKE V_SECTYPE
AND SB.SECTYPE    IN ('001','006','008','011') --Ngay 23/03/2017 CW NamTv them sectype 011
AND OD.AFACCTNO   = AF.ACCTNO
and af.custid = cf.custid
and cf.custatcom = 'Y'
AND AF.ACTYPE     = AFT.ACTYPE
AND AFT.COREBANK  LIKE 'N'
AND AF.BANKNAME   LIKE '%'

 ;

 ELSE

 OPEN PV_REFCURSOR
 FOR
 SELECT (case
          when OD.TRADEPLACE='002' then '1. HNX'
          when OD.TRADEPLACE='001' then '2. HOSE'
          when OD.TRADEPLACE='005' then '3. UPCOM' else '' end) san,
          IOD.symbol symbol,
          iod.custodycd custodycd,
          iod.txtime txdate,
          iod.matchprice matchprice,
          decode(iod.bors,'B',iod.matchqtty,0) sl_buy,
          decode(iod.bors,'B',iod.matchqtty * iod.matchprice ,0) GT_buy,
          decode(iod.bors,'S',iod.matchqtty,0) sl_SELL,
          decode(iod.bors,'S',iod.matchqtty * iod.matchprice ,0) GT_SELL,
          TO_NUMBER(DATE_T) DATET, TRAN_DATE TRAN_DATE
FROM
(
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IOD where deltd <>'Y'
union all
Select orgorderid,codeid,symbol,custodycd,txdate,matchprice,matchqtty,txtime, bors from IODHIST where deltd <>'Y'
)IOD,
(
Select orderid,exectype,clearday,txdate, AFACCTNO,TRADEPLACE from vw_odmast_tradeplace_all where deltd <>'Y'
)OD,
/*(Select orgorderid ,bors,txdate from ood
union all
Select orgorderid ,bors,txdate from oodhist
) ood,*/
sbsecurities sb, AFMAST AF, AFTYPE AFT, cfmast cf
where IOD.orgorderid= OD.orderid
--and IOD.txdate= OD.txdate
----and ood.orgorderid = IOD.orgorderid
---and ood.txdate= OD.txdate
and sb.codeid=iod.codeid
and iod.symbol like  '%'
and od.exectype like '%'
and iod.custodycd like '%'
and od.clearday = TO_NUMBER(DATE_T)
and od.txdate = TO_DATE(I_DATE, 'dd/mm/yyyy')
and (case when V_TRADEPLACE = '999' and OD.TRADEPLACE IN ('001','002') then '999'
                    else OD.TRADEPLACE end) like V_TRADEPLACE
---- AND OD.TRADEPLACE LIKE V_TRADEPLACE
AND OD.TRADEPLACE IN ('001','002','005')
AND SB.SECTYPE    LIKE V_SECTYPE
AND SB.SECTYPE    IN ('001','006','008','011') --Ngay 23/03/2017 CW NamTv them sectype 011
AND OD.AFACCTNO   = AF.ACCTNO
AND AF.ACTYPE     = AFT.ACTYPE
and af.custid = cf.custid
---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0)
AND (af.brid like V_p_STRBRID or instr(V_pV_STRBRID,af.brid) <> 0 )
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
and cf.custatcom = 'Y'
AND AFT.COREBANK  LIKE 'Y'
AND AF.BANKNAME   LIKE V_CASHPLACE

 ;

 END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
