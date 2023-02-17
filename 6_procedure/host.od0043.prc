SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0043 (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   afacctno       IN       VARCHAR2,
   symbol         IN       VARCHAR2,
   maker          IN       VARCHAR2,
   exectype       IN       VARCHAR2,
   tradeplace     IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   28-AUG-09  CREATED
-- ---------   ------  -------------------------------------------
   v_stroption       VARCHAR2 (5);        -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_strbrid         VARCHAR2 (4);        -- USED WHEN V_NUMOPTION > 0
   v_strexectype     VARCHAR2 (5);
   v_strsymbol       VARCHAR2 (20);
   v_strtradeplace   VARCHAR2 (3);
   v_afacctno        VARCHAR2 (100);
   v_strmaker        VARCHAR2 (4);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   v_stroption := opt;

   IF (v_stroption <> 'A') AND (brid <> 'ALL')
   THEN
      v_strbrid := brid;
   ELSE
      v_strbrid := '%';
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (maker <> 'ALL')
   THEN
      v_strmaker := maker;
   ELSE
      v_strmaker := '%';
   END IF;

   IF (tradeplace <> 'ALL')
   THEN
      v_strtradeplace := tradeplace;
   ELSE
      v_strtradeplace := '%';
   END IF;

   --
   IF (symbol <> 'ALL')
   THEN
      v_strsymbol := REPLACE (symbol, ' ', '_');
   ELSE
      v_strsymbol := '%';
   END IF;

   --
   IF (exectype <> 'ALL')
   THEN
      v_strexectype := exectype;
   ELSE
      v_strexectype := '%';
   END IF;

--
   IF (afacctno <> 'ALL')
   THEN
      v_afacctno := afacctno;
   ELSE
      v_afacctno := '%';
   END IF;

   OPEN pv_refcursor FOR
      SELECT   (CASE
                   WHEN v_strmaker = '%'
                      THEN 'ALL'
                   ELSE MAX (TO_CHAR (tlprofiles.tlfullname))
                END
               ) name_maker,
               sb.symbol mack, al.cdcontent san, odm.exectype loailenh,
               odm.afacctno sohd, SUM (ODM.ORDERQTTY - odm.CANCELQTTY - ODM.ADJUSTQTTY) kldat,
               ROUND (  SUM ((ODM.ORDERQTTY - odm.CANCELQTTY - ODM.ADJUSTQTTY) * quoteprice)
                      / SUM (ODM.ORDERQTTY - odm.CANCELQTTY - ODM.ADJUSTQTTY)
                     ) giadatbq,
               NVL (SUM (odm.execqtty), 0) klkhop,
               (CASE
                   WHEN SUM (odm.execqtty) = 0
                      THEN 0
                   ELSE ROUND (SUM (odm.execamt) / SUM (odm.execqtty))
                END
               ) giakhopbq,
               NVL (SUM (odm.execamt), 0) giakhop,
               ROUND (SUM (odm.execqtty) * 100 / SUM (ODM.ORDERQTTY - odm.CANCELQTTY - ODM.ADJUSTQTTY),
                      2
                     ) tilekhop,
               SUM (odm.feeacr) phigd
          FROM (SELECT *
                  FROM odmast
                UNION ALL
                SELECT *
                  FROM odmasthist) odm,
               (SELECT *
                  FROM tllog
                UNION ALL
                SELECT *
                  FROM tllogall) tl,
               sbsecurities sb,
               allcode al,
               tlprofiles
         WHERE odm.txdate = tl.txdate
           AND odm.txnum = tl.txnum
           AND tl.tlid = tlprofiles.tlid
           AND sb.codeid = odm.codeid
           AND al.cdval = sb.tradeplace
           AND al.cdtype = 'OD'
           AND al.cdname = 'TRADEPLACE'
           AND odm.deltd <> 'Y'
           AND odm.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
           AND odm.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
           AND sb.symbol LIKE v_strsymbol
           AND al.CDVAL LIKE v_strtradeplace
           AND INSTR(v_afacctno, odm.afacctno) > 0
           AND odm.exectype IN ('NS', 'MS', 'NB')
           AND odm.exectype LIKE v_strexectype
           AND (ODM.ORDERQTTY - odm.CANCELQTTY - ODM.ADJUSTQTTY) > 0
           AND ODM.ORDERQTTY = (CASE WHEN  SB.TRADEPLACE LIKE '005' AND ODM.ADJUSTQTTY <> 0 THEN  (ODM.ADJUSTQTTY+ODM.REMAINQTTY )
                            ELSE ODM.ORDERQTTY END
                            )
           AND (CASE WHEN odm.exectype IN ('NS', 'MS')
                      THEN tl.tlid
                   ELSE '-'
                END) LIKE v_strmaker
      GROUP BY sb.symbol, al.cdcontent, odm.exectype, odm.afacctno
      ORDER BY sb.symbol
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
