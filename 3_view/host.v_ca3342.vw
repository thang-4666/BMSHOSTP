SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CA3342
(AUTOID, CAMASTID, DESCRIPTION, SYMBOL, ACTIONDATE, 
 POSTINGDATE, ALLAMT, AMT, SCVATAMT, CATYPE, 
 CODEID, ISINCODE, TXDESC)
BEQUEATH DEFINER
AS 
SELECT "AUTOID",
          "CAMASTID",
          "DESCRIPTION",
          "SYMBOL",
          "ACTIONDATE",
          "POSTINGDATE",
          "ALLAMT",
          "AMT",
          "SCVATAMT",
          "CATYPE",
          "CODEID",
          "ISINCODE",
          "TXDESC"
     FROM (  SELECT MAX (A.AUTOID) AUTOID,
                    a.camastid,
                    a.description,
                    b.symbol,
                    a.actiondate,
                    a.actiondate POSTINGDATE,
                    SUM (
                         (CASE
                             WHEN a.catype = '010'
                             THEN
                                (CASE
                                    WHEN chd.status = 'K'
                                    THEN
                                       ROUND ( (100 - a.exerate) / 100, 4)
                                    ELSE
                                       ROUND (a.exerate / 100, 4)
                                 END)
                             ELSE
                                1
                          END)
                       * (CASE
                             WHEN    (CASE
                                         WHEN chd.PITRATEMETHOD <> '##'
                                         THEN
                                            chd.PITRATEMETHOD
                                         ELSE
                                            a.PITRATEMETHOD
                                      END) = 'SC'
                                  OR cf.vat = 'N'
                             THEN
                                chd.amt
                             ELSE
                                (CASE
                                    WHEN a.catype IN ('016', '023')
                                    THEN
                                       ROUND (
                                            chd.amt
                                          - ROUND (
                                               chd.intamt * a.pitrate / 100))
                                    --T9/2019 CW_PhaseII
                                    WHEN a.CATYPE = '028'
                                    THEN
                                         chd.amt
                                       - ROUND (
                                            LEAST (
                                               chd.AMT,
                                                 chd.balance
                                               * a.EXPRICE
                                               * a.pitrate
                                               / 100
                                               / (  TO_NUMBER (
                                                       SUBSTR (
                                                          b.EXERCISERATIO,
                                                          0,
                                                            INSTR (
                                                               b.EXERCISERATIO,
                                                               '/')
                                                          - 1))
                                                  / TO_NUMBER (
                                                       SUBSTR (
                                                          b.EXERCISERATIO,
                                                            INSTR (
                                                               b.EXERCISERATIO,
                                                               '/')
                                                          + 1,
                                                          LENGTH (
                                                             b.EXERCISERATIO))))))
                                    --End --T9/2019 CW_PhaseII
                                    ELSE
                                       ROUND (
                                            chd.amt
                                          - ROUND (chd.amt * a.pitrate / 100))
                                 END)
                          END))
                       allamt,
                    SUM (chd.amt) amt,
                    SUM (
                       CASE
                          WHEN     (CASE
                                       WHEN chd.PITRATEMETHOD <> '##' THEN chd.PITRATEMETHOD
                                       ELSE a.PITRATEMETHOD
                                    END) = 'SC'
                               AND cf.vat = 'Y'
                          THEN
                             (CASE
                                 WHEN a.catype IN ('016', '023')
                                 THEN
                                    ROUND (chd.intamt * a.pitrate / 100)
                                 --T9/2019 CW_PhaseII
                                 WHEN a.CATYPE = '028'
                                 THEN
                                    ROUND (
                                       LEAST (
                                          chd.AMT,
                                            chd.balance
                                          * a.EXPRICE
                                          * a.pitrate
                                          / 100
                                          / (  TO_NUMBER (
                                                  SUBSTR (
                                                     b.EXERCISERATIO,
                                                     0,
                                                       INSTR (b.EXERCISERATIO,
                                                              '/')
                                                     - 1))
                                             / TO_NUMBER (
                                                  SUBSTR (
                                                     b.EXERCISERATIO,
                                                       INSTR (b.EXERCISERATIO,
                                                              '/')
                                                     + 1,
                                                     LENGTH (b.EXERCISERATIO))))))
                                 --End --T9/2019 CW_PhaseII
                                 ELSE
                                    ROUND (chd.amt * a.pitrate / 100)
                              END)
                          ELSE
                             0
                       END)
                       scvatamt,
                    MAX (cd.cdcontent) catype,
                    MAX (a.codeid) codeid,
                    a.isincode,
                    MAX (TX.txdesc) TXDESC
               FROM camast a,
                    sbsecurities b,
                    caschd chd,
                    allcode cd,
                    afmast af,
                    aftype aft,
                    cfmast cf,
                    TLTX TX
              WHERE     a.codeid = b.codeid
                    AND a.status IN ('I',
                                     'G',
                                     'H',
                                     'K')
                    AND chd.afacctno = af.acctno
                    AND af.actype = aft.actype
                    AND af.custid = cf.custid
                    AND a.deltd <> 'Y'
                    AND TX.TLTXCD = '3342'
                    AND a.camastid = chd.camastid
                    AND chd.deltd <> 'Y'
                    AND chd.ISEXEC = 'Y'
                    AND chd.status <> 'C'
                    AND chd.isCI = 'N'
                    AND (SELECT COUNT (1)
                           FROM caschd
                          WHERE     camastid = a.camastid
                                AND status <> 'C'
                                AND isCI = 'N'
                                AND ISEXEC = 'Y'
                                AND amt > 0
                                AND deltd = 'N') > 0
                    AND cd.cdname = 'CATYPE'
                    AND cd.cdtype = 'CA'
                    AND cd.cdval = a.catype
                    AND NOT EXISTS
                               (SELECT 1
                                  FROM tllog tl
                                 WHERE     tl.tltxcd = '3342'
                                       AND tl.deltd <> 'Y'
                                       AND tl.txstatus = '4'
                                       AND tl.msgacct = a.camastid)
           GROUP BY a.isincode,
                    a.camastid,
                    a.description,
                    b.symbol,
                    a.actiondate
             HAVING SUM (chd.amt) <> 0)
    WHERE 0 = 0
/
