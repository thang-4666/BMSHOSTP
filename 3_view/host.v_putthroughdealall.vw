SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_PUTTHROUGHDEALALL
(FULLNAME, CUSTODYCD, ORDERID, QUOTEPRICE, QUOTEQTTY, 
 SELLERCONTRAFIRM, SELLERTRADEID, CONTRAFIRM, TRADERID, SYMBOL, 
 BUY_SELL, ODSTATUS, MATCHPRICE, MATCHQTTY, ISMATCH, 
 CANCELPT, CANCELPTSTATUS, ISCONFIRM, TXDATE, TXTIME, 
 CONFIRMNUMBER, CONFIRMORDER, CONFIRMCANCEL, CANCELORDER, CLIENTID, 
 FIRM, MUA_BAN)
BEQUEATH DEFINER
AS 
SELECT FULLNAME,
            CUSTODYCD,
            orderid,
            quoteprice,
            quoteqtty,
            SELLERCONTRAFIRM,
            SELLERTRADEID,
            contrafirm,
            traderid,
            SYMBOL,
            buy_sell,
            odstatus,
            matchprice,
            matchqtty,
            ismatch,
            cancelpt,
            cancelptstatus,
            isconfirm,
            txdate,
            txtime,
            CONFIRMNUMBER,
            CONFIRMORDER,
            CONFIRMCANCEL,
            CANCELORDER,
            clientid,
            (CASE
                WHEN (CASE
                         WHEN REGEXP_LIKE (sellercontrafirm, '[[:digit:]]')
                         THEN
                            TO_CHAR (TO_NUMBER (sellercontrafirm))
                         ELSE
                            sellercontrafirm
                      END) =
                        (CASE
                            WHEN REGEXP_LIKE (contrafirm, '[[:digit:]]')
                            THEN
                               TO_CHAR (TO_NUMBER (contrafirm))
                            ELSE
                               contrafirm
                         END)                        /*TO_NUMBER(contrafirm)*/
                THEN
                   '1 firm'
                ELSE
                   '2 firm'
             END)
               firm,
            MUA_BAN
       FROM (                        --- LAY THONG TIN LAY THOA THUAN SAN HOSE
             SELECT CF.fullname,
                    CF.custodycd,
                    OD.orderid,
                    OD.quoteprice,
                    OD.orderqtty quoteqtty,
                    SYS.varvalue sellercontrafirm,
                    (CASE
                        WHEN REGEXP_LIKE (SYS.varvalue, '[[:digit:]]')
                        THEN
                           TO_CHAR (TO_NUMBER (SYS.varvalue)) || '1'
                        ELSE
                           SYS.varvalue || '1'
                     END)
                       sellertradeid,
                    -- TO_CHAR(TO_NUMBER(SYS.varvalue)) || '1'  sellertradeid ,
                    NVL (OD.contrafirm, PT.sellercontrafirm) contrafirm,
                    NVL (OD.traderid, PT.sellertradeid) traderid,
                    OOD.symbol,
                    OOD.bors BUY_SELL,
                    (CASE
                        WHEN     OOD.oodstatus = 'B'
                             AND NVL (IOD.matchqtty, 0) <= 0
                        THEN
                           'Ch? d?i tác xác nh?n'
                        WHEN     OOD.oodstatus = 'S'
                             AND OD.DELTD = 'Y'
                             AND NVL (IOD.matchqtty, 0) = 0
                        THEN
                           'DT t? ch?i mua'
                        ELSE
                           (CASE
                               WHEN     OOD.oodstatus = 'S'
                                    AND NVL (IOD.matchqtty, 0) > 0
                               THEN
                                  'Ðã kh?p'
                               ELSE
                                  A1.cdcontent
                            END)
                     END)
                       ODSTATUS,
                    NVL (IOD.matchprice, 0) MATCHPRICE,
                    NVL (IOD.matchqtty, 0) MATCHQTTY,
                    (CASE WHEN NVL (IOD.matchqtty, 0) > 0 THEN 'Y' ELSE 'N' END)
                       ISMATCH,
                    CASE
                       WHEN NVL (CPT.SORR, 'D') = 'R' AND OOD.bors = 'B'
                       THEN
                          (CASE
                              WHEN CPT.isconfirm = 'N'
                              THEN
                                 'DT Xin huy'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'C'
                              THEN
                                 'T? ch?i h?y'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'A'
                              THEN
                                 'Ch?p nh?n h?y'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'S'
                              THEN
                                 'HO t? ch?i'
                              ELSE
                                 'N/A'
                           END)
                       WHEN NVL (CPT.SORR, 'D') = 'S' AND OOD.bors = 'S'
                       THEN
                          (CASE
                              WHEN CPT.status = 'S' AND CPT.isconfirm = 'N'
                              THEN
                                 'Xin h?y'
                              WHEN CPT.status = 'C' AND CPT.isconfirm = 'Y'
                              THEN
                                 'DT t? ch?i'
                              WHEN CPT.status = 'S' AND CPT.isconfirm = 'Y'
                              THEN
                                 'HO t? ch?i'
                              WHEN CPT.status = 'A' AND CPT.isconfirm = 'Y'
                              THEN
                                 'Ch?p nh?n h?y'
                              ELSE
                                 'N/A'
                           END)
                       ELSE
                          (CASE
                              WHEN od.deltd = 'Y' THEN 'Ðã h?y'
                              ELSE 'N/A'
                           END)
                    END
                       CANCELPT,
                    ---(CASE WHEN NVL(CPT.SORR,'D') = 'D' AND OD.cancelqtty = 0 THEN 'N' ELSE 'Y' END) CANCELPTSTATUS,
                    (CASE
                        WHEN NVL (CPT.status, 'D') = 'A'
                        THEN
                           'Y'
                        WHEN     NVL (CPT.status, 'D') = 'S'
                             AND NVL (CPT.isconfirm, 'D') = 'N'
                        THEN
                           'Y'
                        ELSE
                           'N'
                     END)
                       CANCELPTSTATUS,
                    (CASE
                        WHEN NVL (CPT.isconfirm, 'Y') = 'N' THEN 'Y'
                        ELSE 'N'
                     END)
                       isconfirm,
                    OD.txdate,
                    OD.txtime,
                    OD.confirm_no CONFIRMNUMBER,
                    'N' CONFIRMORDER,
                    (CASE
                        WHEN     OOD.BORS = 'B'
                             AND NVL (CPT.SORR, 'D') = 'R'
                             AND NVL (CPT.ISCONFIRM, 'D') = 'N'
                        THEN
                           'Y'
                        ELSE
                           'N'
                     END)
                       CONFIRMCANCEL,
                    (CASE
                        WHEN     OOD.BORS = 'S'
                             AND NVL (IOD.matchqtty, 0) > 0
                             AND OD.cancelqtty = 0
                        THEN
                           'Y'
                        ELSE
                           'N'
                     END)
                       CANCELORDER,
                    od.clientid,
                    A2.cdcontent MUA_BAN
               FROM OOD,
                    sbsecurities SB,
                    CFMAST CF,
                    ALLCODE A1,
                    allcode a2,
                    sysvar SYS,
                    ODMAST OD
                    LEFT JOIN IOD ON OD.orderid = IOD.orgorderid
                    LEFT JOIN
                    (SELECT i.orgorderid orgorderid, c.*
                       FROM CANCELORDERPTACK C, IOD I
                      WHERE     i.norp = 'P'            /*and i.deltd <> 'Y'*/
                            AND TRIM (c.confirmnumber) = TRIM (i.confirm_no))
                    CPT
                       ON TRIM (OD.orderid) = TRIM (CPT.orgorderid)
                    LEFT JOIN orderptack PT ON OD.confirm_no = PT.confirmnumber
              WHERE     OD.orderid = OOD.orgorderid
                    AND OOD.norp = 'P'
                    AND OOD.custodycd = CF.custodycd
                    AND OOD.oodstatus = A1.cdval
                    AND A1.cdtype = 'OD'
                    AND A1.cdname = 'OODSTATUS'
                    AND A1.cduser = 'Y'
                    AND A2.cdtype = 'OD'
                    AND A2.CDNAME = 'BORS'
                    AND A2.CDUSER = 'Y'
                    AND OOD.bors = A2.CDVAL
                    AND SYS.varname = 'FIRM'
                    AND SYS.grname = 'SYSTEM'
                    AND OD.codeid = SB.codeid
                    AND SB.tradeplace = '001'
             UNION ALL
             --- LAY THONG TIN LENH THOA THUAN SAN HNX
             SELECT CF.fullname,
                    CF.custodycd,
                    OD.orderid,
                    OD.quoteprice,
                    OD.orderqtty quoteqtty,
                    SYS.varvalue sellercontrafirm,
                    (CASE
                        WHEN REGEXP_LIKE (SYS.varvalue, '[[:digit:]]')
                        THEN
                           TO_CHAR (TO_NUMBER (SYS.varvalue)) || '1'
                        ELSE
                           SYS.varvalue || '1'
                     END)
                       sellertradeid,
                    ---TO_CHAR(TO_NUMBER(SYS.varvalue)) || '1'  sellertradeid ,
                    NVL (OD.contrafirm, PT.sellercontrafirm) contrafirm,
                    NVL (OD.traderid, PT.sellertradeid) traderid,
                    OOD.symbol,
                    OOD.bors BUY_SELL,
                    (CASE
                        WHEN     OOD.oodstatus = 'B'
                             AND NVL (IOD.matchqtty, 0) <= 0
                             AND NVL (ORHA.REJECTCODE, '1') <> 'Y'
                        THEN
                           'Ch? d?i tác xác nh?n'
                        WHEN     OOD.oodstatus = 'B'
                             AND NVL (IOD.matchqtty, 0) <= 0
                             AND NVL (ORHA.REJECTCODE, '1') = 'Y'
                        THEN
                           'Ðã h?y'
                        WHEN     OOD.oodstatus = 'S'
                             AND OD.DELTD = 'Y'
                             AND NVL (IOD.matchqtty, 0) = 0
                        THEN
                           'DT t? ch?i mua'
                        ELSE
                           (CASE
                               WHEN     OOD.oodstatus = 'S'
                                    AND NVL (IOD.matchqtty, 0) > 0
                               THEN
                                  'Ðã kh?p'
                               ELSE
                                  A1.cdcontent
                            END)
                     END)
                       ODSTATUS,
                    NVL (IOD.matchprice, 0) MATCHPRICE,
                    NVL (IOD.matchqtty, 0) MATCHQTTY,
                    (CASE WHEN NVL (IOD.matchqtty, 0) > 0 THEN 'Y' ELSE 'N' END)
                       ISMATCH,
                    CASE
                       WHEN NVL (CPT.SORR, 'D') = 'R' AND OOD.bors = 'B'
                       THEN
                          (CASE
                              WHEN CPT.isconfirm = 'N'
                              THEN
                                 'DT Xin h?y'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'C'
                              THEN
                                 'T? ch?i h?y'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'A'
                              THEN
                                 'Ch?p nh?n h?y'
                              WHEN CPT.isconfirm = 'Y' AND CPT.status = 'S'
                              THEN
                                 'HO t? ch?i'
                              ELSE
                                 'N/A'
                           END)
                       WHEN NVL (CPT.SORR, 'D') = 'S' AND OOD.bors = 'S'
                       THEN
                          (CASE
                              WHEN CPT.status = 'N' AND CPT.isconfirm = 'S'
                              THEN
                                 'Xin h?y'
                              WHEN CPT.status = 'C' AND CPT.isconfirm = 'Y'
                              THEN
                                 'DT t? ch?i'
                              WHEN CPT.status = 'S' AND CPT.isconfirm = 'Y'
                              THEN
                                 'HO t? ch?i'
                              WHEN CPT.status = 'A' AND CPT.isconfirm = 'Y'
                              THEN
                                 'Ch?p nh?n h?y'
                              ELSE
                                 'N/A'
                           END)
                       ELSE
                          (CASE
                              WHEN    od.deltd = 'Y'
                                   OR NVL (ORHA.REJECTCODE, '1') = 'Y'
                              THEN
                                 'Ðã h?y'
                              ELSE
                                 'N/A'
                           END)
                    END
                       CANCELPT,
                    ---(CASE WHEN NVL(CPT.SORR,'D') = 'D' AND OD.cancelqtty = 0 THEN 'N' ELSE 'Y' END) CANCELPTSTATUS,
                    (CASE
                        WHEN NVL (CPT.status, 'D') = 'A'
                        THEN
                           'Y'
                        WHEN     NVL (CPT.status, 'D') = 'S'
                             AND NVL (CPT.isconfirm, 'D') = 'N'
                        THEN
                           'Y'
                        ELSE
                           'N'
                     END)
                       CANCELPTSTATUS,
                    (CASE
                        WHEN NVL (CPT.isconfirm, 'Y') = 'N' THEN 'Y'
                        ELSE 'N'
                     END)
                       isconfirm,
                    OD.txdate,
                    OD.txtime,
                    NVL (ORHA.ORDER_NUMBER, OD.confirm_no) CONFIRMNUMBER,
                    'N' CONFIRMORDER,
                    (CASE
                        WHEN     OOD.BORS = 'B'
                             AND NVL (CPT.SORR, 'D') = 'R'
                             AND NVL (CPT.ISCONFIRM, 'D') = 'N'
                        THEN
                           (CASE
                               WHEN (CASE
                                        WHEN REGEXP_LIKE (SYS.varvalue,
                                                          '[[:digit:]]')
                                        THEN
                                           TO_CHAR (TO_NUMBER (SYS.varvalue))
                                        ELSE
                                           SYS.varvalue
                                     END) =
                                       (CASE
                                           WHEN REGEXP_LIKE (
                                                   NVL (OD.contrafirm,
                                                        PT.sellercontrafirm),
                                                   '[[:digit:]]')
                                           THEN
                                              TO_CHAR (
                                                 TO_NUMBER (
                                                    NVL (OD.contrafirm,
                                                         PT.sellercontrafirm)))
                                           ELSE
                                              NVL (OD.contrafirm,
                                                   PT.sellercontrafirm)
                                        END)
                               THEN
                                  'N'
                               ELSE
                                  'Y'
                            END)
                        ELSE
                           'N'
                     END)
                       CONFIRMCANCEL,
                    (CASE
                        WHEN     OOD.BORS = 'S'
                             AND NVL (ORHA.REJECTCODE, '1') <> 'Y'
                             AND ( (CASE
                                       WHEN     SB.tradeplace = '002'
                                            AND OOD.oodstatus IN ('S', 'B')
                                       THEN
                                          1
                                       ELSE
                                          NVL (IOD.matchqtty, 0)
                                    END) > 0)
                             AND OD.cancelqtty = 0
                             AND NVL (CPT.status, 'X') NOT IN ('N', 'A')
                        THEN
                           'Y'
                        ELSE
                           'N'
                     END)
                       CANCELORDER,
                    od.clientid,
                    A2.cdcontent MUA_BAN
               FROM OOD,
                    sbsecurities SB,
                    CFMAST CF,
                    ALLCODE A1,
                    allcode a2,
                    sysvar SYS,
                    ODMAST OD
                    LEFT JOIN IOD ON OD.orderid = IOD.orgorderid
                    LEFT JOIN
                    (SELECT i.orgorderid orgorderid, c.*
                       FROM CANCELORDERPTACK C, IOD I
                      WHERE     i.norp = 'P'            /*and i.deltd <> 'Y'*/
                            AND (CASE WHEN i.bors = 'B' THEN 'R' ELSE 'S' END) =
                                   c.sorr
                            AND TRIM (c.confirmnumber) = TRIM (i.confirm_no))
                    CPT
                       ON TRIM (OD.orderid) = TRIM (CPT.orgorderid)
                    LEFT JOIN orderptack PT ON OD.confirm_no = PT.confirmnumber
                    LEFT JOIN
                    (SELECT DISTINCT ORDER_NUMBER, ORGORDERID, REJECTCODE
                       FROM ORDERMAP_HA) ORHA
                       ON OD.orderid = ORHA.orgorderid
              WHERE     OD.orderid = OOD.orgorderid
                    AND OOD.norp = 'P'
                    AND OOD.custodycd = CF.custodycd
                    AND OOD.oodstatus = A1.cdval
                    AND A1.cdtype = 'OD'
                    AND A1.cdname = 'OODSTATUS'
                    AND A1.cduser = 'Y'
                    AND A2.cdtype = 'OD'
                    AND A2.CDNAME = 'BORS'
                    AND A2.CDUSER = 'Y'
                    AND OOD.bors = A2.CDVAL
                    AND SYS.varname = 'FIRM'
                    AND SYS.grname = 'SYSTEM'
                    AND OD.codeid = SB.codeid
                    AND SB.tradeplace IN ('002', '005')
             ---AND SB.tradeplace <> '001'
             UNION ALL
             SELECT A.SELLERCONTRAFIRM FULLNAME,
                    A.SELLERTRADEID CUSTODYCD,
                    A.CONFIRMNUMBER orderid,
                    (CASE
                        WHEN sb.tradeplace = '001'
                        THEN
                           TO_NUMBER (A.PRICE) / 1000
                        ELSE
                           TO_NUMBER (A.PRICE)
                     END)
                       quoteprice,
                    TO_NUMBER (A.VOLUME) quoteqtty,
                    A.SELLERCONTRAFIRM,
                    A.SELLERTRADEID,
                    A.FIRM contrafirm,
                    A.BUYERTRADEID traderid,
                    A.SECURITYSYMBOL SYMBOL,
                    'S' buy_sell,
                    'Ch? xác nh?n' odstatus,
                    0 matchprice,
                    0 matchqtty,
                    'N' ismatch,
                    'N/A' cancelpt,
                    'N' cancelptstatus,
                    'N' isconfirm,
                    A.TRADING_DATE txdate,
                    A.txtime txtime,
                    A.CONFIRMNUMBER,
                    'Y' CONFIRMORDER,
                    'N' CONFIRMCANCEL,
                    'N' CANCELORDER,
                    '' clientid,
                    'Bán' MUA_BAN
               FROM orderptack A, sbsecurities sb
              WHERE     A.STATUS = 'N'
                    AND a.side = 'B'
                    AND TRIM (a.SECURITYSYMBOL) = sb.symbol
                    AND A.confirmnumber NOT IN (SELECT NVL (TLF.CVALUE, 'X')
                                                  FROM TLLOG TL, TLLOGFLD TLF
                                                 WHERE     TL.TLTXCD = '8876'
                                                       AND TL.TXSTATUS = '4'
                                                       AND TL.TXNUM = TLF.TXNUM
                                                       AND TL.TXDATE =
                                                              TLF.TXDATE
                                                       AND TLF.fldcd = '86')
                    AND NOT EXISTS
                               (SELECT *
                                  FROM IOD
                                 WHERE     IOD.DELTD <> 'Y'
                                       AND IOD.CONFIRM_NO = A.CONFIRMNUMBER
                                       AND IOD.NORP = 'P'))
   ORDER BY txdate, txtime
/
