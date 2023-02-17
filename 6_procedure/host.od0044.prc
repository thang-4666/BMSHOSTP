SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0044 (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   acctno         IN       VARCHAR2,
   symbol         IN       VARCHAR2,
   maker          IN       VARCHAR2,
   exectype       IN       VARCHAR2
)
IS
-- KET QUA KHOP LENH CUA KHACH HANG

-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS

   -- ---------   ------  -------------------------------------------
   v_stroption     VARCHAR2 (5);          -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_strbrid       VARCHAR2 (4);                 -- USED WHEN V_NUMOPTION > 0
   v_strsymbol     VARCHAR2 (20);
   v_stracctno     VARCHAR2 (100);
   v_strexectype   VARCHAR2 (5);
   v_strmaker      VARCHAR2 (4);
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

   --
   IF (maker <> 'ALL')
   THEN
      v_strmaker := maker;
   ELSE
      v_strmaker := '%';
   END IF;

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
   IF (acctno <> 'ALL')
   THEN
      v_stracctno := acctno;
   ELSE
      v_stracctno := '%';
   END IF;

   OPEN pv_refcursor FOR
      SELECT t.name_maker, t.orderid, t.symbol, t.afacctno, t.exectype,
             NVL (t.orderqtty, 0) orderqtty, NVL (t.quoteprice, 0) quoteprice,
             NVL (io.matchqtty, 0) matchqtty,
             NVL (io.matchprice, 0) matchprice,
             NVL (io.matchqtty * io.matchprice, 0) price,
             NVL (t.feeacr, 0) feearc
        FROM (SELECT   odm.orderid, sb.symbol, odm.afacctno, odm.exectype,
                       odm.orderqtty, odm.quoteprice, odm.feeacr,
                       (CASE
                           WHEN v_strmaker = '%'
                              THEN 'ALL'
                           ELSE TO_CHAR (tlprofiles.tlfullname)
                        END
                       ) name_maker
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
                       tlprofiles,
                       sbsecurities sb
                 WHERE odm.codeid = sb.codeid
                   AND tl.tlid = tlprofiles.tlid
                   AND odm.txdate = tl.txdate
                   AND odm.txnum = tl.txnum
                   AND odm.deltd <> 'Y'
                   AND odm.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
                   AND odm.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
                   AND odm.exectype LIKE v_strexectype
                   AND sb.symbol LIKE v_strsymbol
                   AND INSTR (v_stracctno, odm.afacctno) > 0
                   AND (CASE
                           WHEN odm.exectype IN ('NS', 'MS')
                              THEN tl.tlid
                           ELSE '-'
                        END
                       ) LIKE v_strmaker
              ORDER BY odm.afacctno) t LEFT JOIN (SELECT *
                                                    FROM iod
                                                   WHERE deltd <> 'Y'
                                                  UNION ALL
                                                  SELECT *
                                                    FROM iodhist
                                                   WHERE deltd <> 'Y') io ON io.orgorderid =
                                                                               t.orderid
             ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
