SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0045 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   EXECTYPE       IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   CIACCTNO       IN       VARCHAR2,
   ORDERSTATUS    in       varchar2
      )
IS
-- KET QUA KHOP LENH CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);               -- USED WHEN V_NUMOPTION > 0
   V_STREXECTYPE    VARCHAR2 (5);
   V_STRSYMBOL      VARCHAR2 (20);
   V_STRTRADEPLACE  VARCHAR2 (3);
   V_CIACCTNO       VARCHAR2 (10);
   v_ORDERSTATUS    varchar2(4);
   v_clause         varchar2(2000);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS

   --
    IF (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := SYMBOL;
   ELSE
      V_STRSYMBOL := '%%';
   END IF;
   --
   IF (EXECTYPE <> 'ALL')
   THEN
      V_STREXECTYPE := EXECTYPE;
   ELSE
      V_STREXECTYPE := '%%';
   END IF;
   --
    IF (ORDERSTATUS <> 'ALL')
   THEN
      V_ORDERSTATUS := ORDERSTATUS;
   ELSE
      V_ORDERSTATUS := '%%';
   END IF;
   ---
   if length(CIACCTNO)=0 then
   V_CIACCTNO:='ALL';
   end if;
   V_CIACCTNO := nvl(CIACCTNO,'ALL');
   -- GET REPORT'S DATA
   OPEN PV_REFCURSOR
   FOR
   SELECT fo.acctno  foacctno,
       NVL (orgacctno, '----------------') orderid,
       afacctno afacctno,
       cf.custodycd  custodycd,
       se.symbol codeid,
       fo.txdate,
       fo.expdate,
       a1.cdcontent timetype,
       a2.cdcontent exectype,
       TO_CHAR (a8.cdcontent) orstatus,
       fo.quoteprice * inf.tradeunit quoteprice,
       fo.quantity orderqtty,
       fo.remainqtty,
       fo.execqtty,
       TO_CHAR (a8.cdcontent) oodstatus,
       fo.deltd
  FROM (select * from fomast union all select * from fomasthist) fo,
       afmast af,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
       allcode a1,
       allcode a2,
       allcode a8,
       sbsecurities se,
       securities_info inf
 WHERE --fo.deltd <> 'Y'
   --AND fo.cancelqtty = 0
    se.codeid = fo.codeid
   AND se.codeid = inf.codeid
   AND a8.cdtype = 'FO'
   AND a8.cdname = 'STATUS'
   AND a8.cdval = fo.status
   AND a1.cdtype = 'OD'
   AND a1.cdname = 'TIMETYPE'
   AND a1.cdval = timetype
   AND a2.cdtype = 'OD'
   AND a2.cdname = 'EXECTYPE'
   AND a2.cdval = exectype

   AND fo.afacctno = af.acctno
   AND af.custid = cf.custid
   AND timetype = 'G'
   AND NVL (fo.txnum, '') || NVL (fo.txdate, '') NOT IN (
                                                        SELECT txnum || txdate
                                                          FROM tllog
                                                         WHERE txstatus <> '1')
  and  (V_CIACCTNO ='ALL' or afacctno=V_CIACCTNO)
  and fo.txdate>= to_date(f_date,'dd/mm/yyyy')
  and fo.txdate<=to_date(t_date,'dd/mm/yyyy')
  and fo.exectype like V_STREXECTYPE
   and fo.status like v_orderstatus
   and se.symbol like v_strsymbol
  order by afacctno, fo.txdate ;





EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
