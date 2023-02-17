SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se200901
(
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2

 )
IS

--
-- BAO CAO THE HIEN CK PHAT SINH TU QUYEN CHUYEN KHOAN RA NGOAI
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- TANPN   23/12/2020  CREATED
-- ---------   ------  -------------------------------------------
   V_STRCUSTODYCD          VARCHAR2 (20);
   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(20);
   V_CUSTODYCD    VARCHAR2(20);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN


      V_STROPT := OPT;

   IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;



   if PV_CUSTODYCD = 'ALL' then
    V_CUSTODYCD:='%%';
    else
    V_CUSTODYCD:= PV_CUSTODYCD;
    end if;

    OPEN PV_REFCURSOR
    FOR
   select cf.fullname,sb.symbol,cf.custodycd ,ses.recustodycd, sum(log.qtty) qtty,sum(log.qtty) qttywft,sep.catype,a1.cdcontent tradeplace
    from SE2244_LOG log, cfmast cf, afmast af, sepitlog sep, sbsecurities sb, allcode a1,
    (  select autoid, recustodycd recustodycd, txdate, '2244' tltxcd, outward ward from SESENDOUT where deltd = 'N'
       union all
       select autoid, rcvcustodycd recustodycd, txdate, '2257' tltxcd, inward ward from sefulltransfer_log where deltd = 'N'
       union all
       select autoid, receivcustodycd recustodycd, txdate, '2247' tltxcd, bank ward from SESENDCLOSE where deltd = 'N'
    ) ses
    where cf.custid = af.custid
            and af.acctno = log.afacctno
            and cf.custodycd like V_CUSTODYCD
            and sep.autoid = log.sepitid
            and ses.autoid = log.sendoutid
          --  and ses.tltxcd=log.tltxcd
            and sb.codeid = log.codeid
            and log.deltd <> 'Y'
            and sep.catype = '011'
            and a1.cdname='TRADEPLACE' and a1.cdtype='SE'
            and a1.cdval= (case when SUBSTR(sb.symbol,-3,3) = 'WFT' then (select tradeplace from sbsecurities where codeid=sb.refcodeid)
                else sb.tradeplace end)
            and ses.txdate BETWEEN TO_DATE (F_DATE  ,'DD/MM/YYYY') AND TO_DATE (T_DATE  ,'DD/MM/YYYY')
    group by cf.fullname,sb.symbol,cf.custodycd ,sep.catype,a1.cdcontent,ses.recustodycd
                ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
