SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se2009
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
        select distinct cf.fullname, cf.idcode ,cf.iddate ,cf.custodycd ,ses.recustodycd ,dep.fullname fullnamese
       -- ,sb.symbol, sum(log.qtty) qtty,sep.catype,sb.tradeplace
        from SE2244_LOG log, cfmast cf, afmast af, sepitlog sep, sbsecurities sb,deposit_member dep,
        (   select autoid, recustodycd recustodycd, txdate, '2244' tltxcd, outward ward from SESENDOUT where deltd = 'N'
            union all
            select autoid, rcvcustodycd recustodycd, txdate, '2257' tltxcd, inward ward from sefulltransfer_log where deltd = 'N'
            union all
            select autoid, receivcustodycd recustodycd, txdate, '2247' tltxcd, bank ward  from SESENDCLOSE where deltd = 'N'
        ) ses
        where cf.custid = af.custid
                and af.acctno = log.afacctno
                and cf.custodycd like V_CUSTODYCD
                and sep.autoid = log.sepitid
                and ses.autoid = log.sendoutid
              --  and ses.tltxcd=log.tltxcd
                and sb.codeid = log.codeid
                and log.deltd <> 'Y'
                and sep.catype in ('011','021')
                and ses.txdate BETWEEN TO_DATE (F_DATE  ,'DD/MM/YYYY') AND TO_DATE (T_DATE  ,'DD/MM/YYYY')
                and dep.depositid = ses.ward
        group by cf.fullname, cf.idcode ,cf.iddate ,cf.custodycd ,ses.recustodycd ,dep.fullname
       -- ,sb.symbol,sep.catype,sb.tradeplace
                ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
