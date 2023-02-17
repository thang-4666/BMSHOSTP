SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0023" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2(5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2(4);       -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD     VARCHAR2(20);

   v_Fullname    VARCHAR2(255);
   v_Address     VARCHAR2(255);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS



    V_STRCUSTODYCD := CUSTODYCD;
    SELECT cf.fullname, cf.address INTO v_Fullname,v_Address  FROM cfmast cf WHERE  cf.custodycd = V_STRCUSTODYCD ;

   OPEN PV_REFCURSOR
       FOR
    SELECT
        se.acctno acctno,v_Fullname fullname ,v_Address address, I_DATE I_DATE, V_STRCUSTODYCD CUSTODYCD, sb.symbol symbol,
       (se.trade - NVL (num.trade, 0)) TRADE,
       (se.blocked+se.emkqtty- NVL (num.blocked, 0)) BLOCKED,
       (se.mortage - NVL (num.mortage, 0)) MORTAGE,
       (se.senddeposit + se.deposit - NVL (num.deposit, 0)) DEPOSIT,
       (se.receiving - NVL (num.receiving, 0)) RECEIVING,
       --(se.secured - NVL (num.secured, 0)),
       (se.dtoclose + se.withdraw - NVL (num.dtoclose, 0)) DTOCLOSE,
       (se.netting - NVL (num.netting, 0)) NETTING
       --into v_Ftrade, v_Fblocked, v_Fmortage, v_Fsenddeposit, v_Fsts, v_Fsecured, v_Fdtoclose, v_Fnetting
    From
     semast se,sbsecurities sb,
     (
           SELECT
               sum(decode(app.FIELD,'TRADE',decode( app.txtype,'D',-tr.namt,'C',tr.namt,0),0))  TRADE,
               sum(decode(app.FIELD,'SECURED',decode( app.txtype,'D',-tr.namt,'C',tr.namt,0),0))  SECURED,
               sum(decode(app.FIELD,'MORTAGE',decode( app.txtype,'D',-tr.namt,'C',tr.namt,0),0))  MORTAGE,
               sum(case when app.field in ('BLOCKED','EMKQTTY') then
                    (case when app.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) BLOCKED ,
               sum(decode(instr('DEPOSITSENDDEPOSIT',app.FIELD),0,0,decode( app.txtype,'D',-tr.namt,'C',tr.namt,0)))DEPOSIT ,
               sum(decode(instr('DTOCLOSEWITHDRAW',app.FIELD),0,0,decode( app.txtype,'D',-tr.namt,'C',tr.namt,0)))DTOCLOSE ,
               sum(decode(app.FIELD,'RECEIVING',decode( app.txtype,'D',-tr.namt,'C',tr.namt,0),0))  RECEIVING ,
               sum(decode(app.FIELD,'NETTING',decode( app.txtype,'D',-tr.namt,'C',tr.namt,0),0))  NETTING ,
               tr.acctno acctno
            FROM  apptx app,
              (select * from setran
                    union all
                   select * from setrana)  tr,
                  (select * from tllog
                    union all
                  select * from  tllogall) tl
            WHERE
                   tr.txcd = app.txcd
                   AND tl.txnum = tr.txnum
                   AND tl.txdate = tr.txdate
                   --and substr(tr.acctno,0,10) like V_STRAFACCTNO||'%'
                   AND exists (SELECT SE.acctno FROM vw_custodycd_subaccount vw, semast se
                          WHERE tr.acctno = se.acctno
                          and vw.value = se.afacctno
                          and vw.filtercd like V_STRCUSTODYCD)
                   AND app.apptype = 'SE'
                   AND app.txtype IN ('C', 'D')
                   AND tl.deltd <> 'Y'
                   AND tl.busdate > TO_DATE (I_DATE, 'DD/MM/YYYY')
           group by  tr.acctno
      ) num
      /*(SELECT   acctno, SUM (qtty) qtty
                          FROM semastdtl
                         WHERE deltd <> 'Y'
                      GROUP BY acctno) b */
    where se.acctno = num.acctno(+)
    ---    and se.acctno = b.acctno(+)
        and SUBSTR (se.acctno, 11, 6) = sb.codeid
        and SUBSTR (se.afacctno, 1, 4) LIKE V_STRBRID
        --and se.afacctno = V_STRAFACCTNO
        and se.acctno in (SELECT SE.acctno
                            FROM vw_custodycd_subaccount vw, semast se
                            WHERE vw.value = se.afacctno
                            and vw.filtercd like V_STRCUSTODYCD)
        and ((se.trade - NVL (num.trade, 0)) <>0
---        or  (b.qtty - NVL (num.blocked, 0))<>0
        or  (se.mortage - NVL (num.mortage, 0)) <>0
        or  (se.senddeposit + se.deposit - NVL (num.deposit, 0)) <>0
        or  (se.receiving - NVL (num.receiving, 0)) <>0
        or  (se.secured - NVL (num.secured, 0)) <>0
        or  (se.dtoclose + se.withdraw - NVL (num.dtoclose, 0)) <>0
        or  (se.netting - NVL (num.netting, 0)) <> 0)
    order by SUBSTR (se.acctno, 11, 6);
 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
