SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CAMAST
(VALUE, AUTOID, SYMBOL, CAMASTID, CODEID, 
 EXCODEID, TYPEID, CATYPE, KHQDATE, REPORTDATE, 
 DUEDATE, ACTIONDATE, BEGINDATE, EXPRICE, EXRATE, 
 RIGHTOFFRATE, DEVIDENTRATE, OPTCODEID, DEVIDENTSHARES, SPLITRATE, 
 INTERESTRATE, DESCRIPTION, CONTENTS, INTERESTPERIOD, STATUS, 
 FRDATERETAIL, TODATERETAIL, TRFLIMIT, ROPRICE, TVPRICE, 
 RATE, PITRATE, PITRATEMETHOD_CD, PITRATEMETHOD, CATYPEVAL, 
 FRDATETRANSFER, TODATETRANSFER, DEVIDENTVALUE, APRALLOW, PITRATESE, 
 INACTIONDATE, AMT, QTTY, TAXAMT, AMTAFTER, 
 STATUSVAL, ISCHANGESTT, MAKERID, APPRVID, ISRIGHTOFF, 
 TRADE, TRADE3375, TOSYMBOL, TOCODEID, CAQTTY, 
 CANCELDATE, RECEIVEDATE, ISINCODE, TRADEDATE, TOTALQTTY)
BEQUEATH DEFINER
AS 
(SELECT CAMAST.CAMASTID VALUE,
           CAMAST.AUTOID,
           SYM.SYMBOL,
              SUBSTR (CAMAST.CAMASTID, 1, 4)
           || '.'
           || SUBSTR (CAMAST.CAMASTID, 5, 6)
           || '.'
           || SUBSTR (CAMAST.CAMASTID, 11, 6)
              CAMASTID,
           CAMAST.CODEID,
           CAMAST.EXCODEID,
           A1.CDVAL TYPEID,
           A1.CDCONTENT CATYPE,
           getprevdate (REPORTDATE, 2) KHQDATE,
           REPORTDATE,
           DUEDATE,
           ACTIONDATE,
           BEGINDATE,
           EXPRICE,
           EXRATE,
           RIGHTOFFRATE,
           DEVIDENTRATE,
           OPTCODEID,
           DEVIDENTSHARES,
           SPLITRATE,
           INTERESTRATE,
           CAMAST.DESCRIPTION,
           CAMAST.DESCRIPTION CONTENTS,
           INTERESTPERIOD,
           A2.CDCONTENT STATUS,
           FRDATERETAIL,
           TODATERETAIL,
           TRFLIMIT,
           (CASE WHEN CAMAST.CATYPE = '014' THEN CAMAST.EXPRICE END) ROPRICE,
           (CASE WHEN CAMAST.CATYPE = '011' THEN CAMAST.EXPRICE END) TVPRICE,
           (CASE
               WHEN EXRATE IS NOT NULL
               THEN
                  EXRATE
               ELSE
                  (CASE
                      WHEN RIGHTOFFRATE IS NOT NULL
                      THEN
                         RIGHTOFFRATE
                      ELSE
                         (CASE
                             WHEN DEVIDENTRATE IS NOT NULL
                             THEN
                                DEVIDENTRATE
                             ELSE
                                (CASE
                                    WHEN SPLITRATE IS NOT NULL
                                    THEN
                                       SPLITRATE
                                    ELSE
                                       (CASE
                                           WHEN INTERESTRATE IS NOT NULL
                                           THEN
                                              INTERESTRATE
                                           ELSE
                                              (CASE
                                                  WHEN DEVIDENTSHARES
                                                          IS NOT NULL
                                                  THEN
                                                     DEVIDENTSHARES
                                                  ELSE
                                                     '0'
                                               END)
                                        END)
                                 END)
                          END)
                   END)
            END)
              RATE,
           CASE
              WHEN PITRATE = 0 THEN TO_NUMBER (SYS.VARVALUE)
              ELSE TO_NUMBER (PITRATE)
           END
              PITRATE,
           A3.CDVAL PITRATEMETHOD_CD,
           A3.CDCONTENT PITRATEMETHOD,
           CAMAST.CATYPE CATYPEVAL,
           FRDATETRANSFER,
           TODATETRANSFER,
           DEVIDENTVALUE,
           (CASE WHEN CAMAST.STATUS IN ('P') THEN 'Y' ELSE 'N' END) APRALLOW,
           CASE
              WHEN PITRATESE = 0 THEN TO_NUMBER (SYSSE.VARVALUE)
              ELSE TO_NUMBER (PITRATESE)
           END
              PITRATESE,
           NVL (inactiondate, actiondate) INACTIONDATE,
           NVL (schd.amt, 0) amt,
           NVL (schd.qtty, 0) qtty,
           NVL (schd.taxamt, 0) taxamt,
           NVL (schd.amtafter, 0) amtafter,
           camast.status statusval,
           (CASE WHEN camast.status = 'S' THEN 1 ELSE 0 END) ISCHANGESTT,
           maker.tlname makerid,
           apprv.tlname apprvid,
           (CASE WHEN CAMAST.CATYPE = '014' THEN 1 ELSE 0 END) ISRIGHTOFF,
           NVL (schd2.TRADE, 0) trade,
           NVL (SE.trade, 0) trade3375,
           tosym.symbol tosymbol,
           NVL (camast.tocodeid, camast.codeid) tocodeid,
           NVL (schd2.QTTY, 0) CAQTTY,
           NVL (camast.CANCELDATE, TO_DATE ('20/03/2050', 'DD/MM/RRRR'))
              CANCELDATE,
           NVL (camast.RECEIVEDATE, TO_DATE ('20/03/2050', 'DD/MM/RRRR'))
              RECEIVEDATE,
           camast.isincode,
           CAMAST.TRADEDATE,
           NVL (schd2.TOTALQTTY, 0) TOTALQTTY
      FROM CAMAST,
           SBSECURITIES SYM,
           ALLCODE A1,
           ALLCODE A2,
           ALLCODE A3,
           (  SELECT SUM (CASE WHEN schd.isci = 'Y' THEN schd.amt ELSE 0 END)
                        amt,
                     SUM (CASE WHEN schd.isse = 'Y' THEN schd.qtty ELSE 0 END)
                        qtty,
                     SUM (
                        ROUND (
                             mst.pitrate
                           * (CASE
                                 WHEN (CASE
                                          WHEN schd.pitratemethod = '##'
                                          THEN
                                             mst.pitratemethod
                                          ELSE
                                             schd.pitratemethod
                                       END) = 'SC'
                                 THEN
                                    1
                                 ELSE
                                    0
                              END)
                           * (CASE
                                 WHEN (schd.isci = 'Y' AND cf.vat = 'Y')
                                 THEN
                                    (CASE
                                        WHEN mst.catype = '016'
                                        THEN
                                           schd.intamt
                                        ELSE
                                           schd.amt
                                     END)
                                 ELSE
                                    0
                              END)
                           / 100))
                        taxamt,
                     SUM (
                          (CASE WHEN schd.isci = 'Y' THEN schd.amt ELSE 0 END)
                        - ROUND (
                               mst.pitrate
                             * (CASE
                                   WHEN (CASE
                                            WHEN schd.pitratemethod = '##'
                                            THEN
                                               mst.pitratemethod
                                            ELSE
                                               schd.pitratemethod
                                         END) = 'SC'
                                   THEN
                                      0
                                   ELSE
                                      1
                                END)
                             * (CASE
                                   WHEN (schd.isci = 'Y' AND cf.vat = 'Y')
                                   THEN
                                      (CASE
                                          WHEN mst.catype = '016'
                                          THEN
                                             schd.intamt
                                          ELSE
                                             schd.amt
                                       END)
                                   ELSE
                                      0
                                END)
                             / 100))
                        amtafter,
                     schd.camastid
                FROM caschd schd,
                     camast mst,
                     afmast af,
                     aftype aft,
                     cfmast cf
               WHERE     schd.deltd = 'N'
                     AND mst.deltd = 'N'
                     AND af.custid = cf.custid
                     AND mst.camastid = schd.camastid
                     AND schd.afacctno = af.acctno
                     AND af.actype = aft.actype
            GROUP BY schd.camastid) SCHD,
           tlprofiles maker,
           tlprofiles apprv,
           (  SELECT SUM (NVL (trade, 0)) trade,
                     SUM (NVL (QTTY, 0)) QTTY,
                     SUM (BALANCE) TOTALQTTY,
                     camastid
                FROM caschd
               WHERE deltd = 'N' AND isexec <> 'N' AND STATUS <> 'O'
            GROUP BY camastid) schd2,
           (  SELECT SUM (
                          TRADE
                        + MARGIN
                        + WTRADE
                        + MORTAGE
                        + BLOCKED
                        + SECURED
                        + REPO
                        + NETTING
                        + DTOCLOSE
                        + WITHDRAW)
                        trade,
                     cODEid
                FROM SEMAST
            GROUP BY CODEID) SE,
           SBSECURITIES TOSYM,
           SYSVAR SYS,
           SYSVAR SYSSE
     WHERE     CAMAST.CODEID = SYM.CODEID
           AND CAMAST.CODEID = SE.CODEID(+)
           AND A1.CDTYPE = 'CA'
           AND A1.CDNAME = 'CATYPE'
           AND A1.CDVAL = CATYPE
           AND A3.CDTYPE = 'CA'
           AND A3.CDNAME = 'PITRATEMETHOD'
           AND CAMAST.PITRATEMETHOD = A3.CDVAL
           AND A2.CDTYPE = 'CA'
           AND A2.CDNAME = 'CASTATUS'
           AND CAMAST.STATUS = A2.CDVAL
           AND CAMAST.DELTD = 'N'
           AND camast.camastid = schd.camastid(+)
           AND camast.makerid = maker.tlid(+)
           AND camast.apprvid = apprv.tlid(+)
           AND camast.camastid = schd2.camastid(+)
           AND NVL (camast.tocodeid, camast.codeid) = tosym.codeid
           AND SYS.VARNAME = 'PITRATE'
           AND SYSSE.VARNAME = 'PITRATESE')
/
