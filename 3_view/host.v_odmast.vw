SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ODMAST
(ORDERID, REFORDERID, TRADEPLACE, AFACCTNO, CUSTODYCD, 
 SYMBOL, ORSTATUS, EDSTATUS, ACTYPE, VIA, 
 MAKER, OFFICER, MAKETIME, APPRTIME, SENDTIME, 
 TIMETYPE, TXNUM, TXDATE, EXPDATE, BRATIO, 
 EXECTYPE, NORK, MATCHTYPE, CLEARDAY, CLEARCD, 
 PRICETYPE, QUOTEPRICE, STOPPRICE, LIMITPRICE, ORDERQTTY, 
 REMAINQTTY, EXECQTTY, STANDQTTY, CANCELQTTY, ADJUSTQTTY, 
 REJECTQTTY, REJECTCD, EXPRICE, EXQTTY, DELTD, 
 MAPORDERID, FOACCTNO, PUTTYPE, CONTRAORDERID, CONTRAFRM)
BEQUEATH DEFINER
AS 
(SELECT od.orderid orderid, od.reforderid, a0.cdcontent tradeplace,
           SUBSTR (od.afacctno, 1, 4)
        || '.'
        || SUBSTR (od.afacctno, 5, 6) afacctno,
           SUBSTR (cf.custodycd, 1, 3)
        || '.'
        || SUBSTR (cf.custodycd, 4, 1)
        || '.'
        || SUBSTR (cf.custodycd, 5, 6) custodycd,
        se.symbol symbol, a1.cdcontent orstatus, a10.cdcontent edstatus,
        ot.typename actype, a2.cdcontent via, nvl(od.username,mk.tlname) maker,
        ofc.tlname officer, od.txtime maketime,
        NVL (tlg.offtime, '____') apprtime, NVL (od.sendtime,
                                                 '____') sendtime,
        a3.cdcontent timetype, od.txnum, od.txdate, od.expdate, od.bratio,
        a4.cdcontent exectype, od.nork, a5.cdcontent matchtype, od.clearday,
        a6.cdcontent clearcd, a7.cdcontent pricetype, od.quoteprice,
        od.stopprice, od.limitprice, od.orderqtty, od.remainqtty, od.execqtty,
        od.standqtty, od.cancelqtty, od.adjustqtty, od.rejectqtty,
        a8.cdcontent rejectcd, od.exprice, od.exqtty, a9.cdcontent deltd,
        od.maporderid, od.foacctno, od.puttype, od.contraorderid,
        od.contrafrm
   FROM afmast af,
        cfmast cf,
        sbsecurities se,
        odtype ot,
        allcode a0,
        allcode a1,
        allcode a2,
        allcode a3,
        allcode a4,
        allcode a5,
        allcode a6,
        allcode a7,
        allcode a8,
        allcode a9,
        allcode a10,
        (SELECT od.*, ood.txtime sendtime
           FROM (SELECT od.*, NVL (bk.ordernumber, '') maporderid, '' username
                   FROM odmast od, stcorderbook bk
                  WHERE od.orderid = bk.orderid(+)
                  and od.via<>'B'
                 UNION ALL
                 SELECT od.*, NVL (bk.ordernumber, '') maporderid,  '' username
                   FROM odmasthist od, stcorderbookhist bk
                  WHERE od.orderid = bk.orderid(+)
                    and od.via<>'B'
                    AND od.txdate >=
                           TO_DATE ((SELECT varvalue
                                       FROM sysvar
                                      WHERE varname = 'DUEDATE'
                                        AND grname = 'SYSTEM'),
                                    'DD/MM/YYYY'
                                   )
                  union all
                  SELECT od.*, NVL (bk.ordernumber, '') maporderid, fo.username
                   FROM odmast od, stcorderbook bk, fomast fo
                  WHERE od.via = 'B'
                  and od.orderid = bk.orderid(+)
                  and od.orderid=fo.orgacctno(+)
                  and 'A'=fo.status(+)
                 UNION ALL
                 SELECT od.*, NVL (bk.ordernumber, '') maporderid,  fo.username
                   FROM odmasthist od, stcorderbookhist bk, fomasthist fo
                  WHERE  od.via = 'B'
                  and od.orderid = bk.orderid(+)
                  and  od.orderid=fo.orgacctno(+)
                  and 'A'=fo.status(+)
                    AND od.txdate >=
                           TO_DATE ((SELECT varvalue
                                       FROM sysvar
                                      WHERE varname = 'DUEDATE'
                                        AND grname = 'SYSTEM'),
                                    'DD/MM/YYYY'
                                   )) od,
                (SELECT txtime, orgorderid
                   FROM ood
                 UNION ALL
                 SELECT txtime, orgorderid
                   FROM oodhist
                   where txdate >=
                           TO_DATE ((SELECT varvalue
                                       FROM sysvar
                                      WHERE varname = 'DUEDATE'
                                        AND grname = 'SYSTEM'),
                                    'DD/MM/YYYY'
                                   )
                    ) ood
          WHERE od.orderid = ood.orgorderid(+)) od,
        (SELECT tlid, tlname
           FROM tlprofiles
         UNION ALL
         SELECT '____' tlid, '____' tlname
           FROM DUAL
         ) mk,
        (SELECT tlid, tlname
           FROM tlprofiles
         UNION ALL
         SELECT '____' tlid, '____' tlname
           FROM DUAL
         ) ofc,
        (SELECT txdate, txnum, tlid, offid, txtime, offtime, tltxcd, deltd,
                txstatus
           FROM tllog
         UNION ALL
         SELECT txdate, txnum, tlid, offid, txtime, offtime, tltxcd, deltd,
                txstatus
           FROM tllogall
        where txdate >=
                           TO_DATE ((SELECT varvalue
                                       FROM sysvar
                                      WHERE varname = 'DUEDATE'
                                        AND grname = 'SYSTEM'),
                                    'DD/MM/YYYY'
                                   )
                           ) tlg
  WHERE od.afacctno = af.acctno
    AND af.custid = cf.custid
    AND od.codeid = se.codeid
    AND od.actype = ot.actype
    AND a10.cdtype = 'OD'
    AND a10.cdname = 'EDSTATUS'
    AND a10.cdval = od.edstatus
    AND a0.cdtype = 'OD'
    AND a0.cdname = 'TRADEPLACE'
    AND a0.cdval = se.tradeplace
    AND a2.cdtype = 'OD'
    AND a2.cdname = 'VIA'
    AND a2.cdval = od.via
    AND a3.cdtype = 'OD'
    AND a3.cdname = 'TIMETYPE'
    AND a3.cdval = od.timetype
    AND a4.cdtype = 'OD'
    AND a4.cdname = 'EXECTYPE'
    AND a4.cdval = od.exectype
    AND a5.cdtype = 'OD'
    AND a5.cdname = 'MATCHTYPE'
    AND a5.cdval = od.matchtype
    AND a6.cdtype = 'OD'
    AND a6.cdname = 'CLEARCD'
    AND a6.cdval = od.clearcd
    AND a7.cdtype = 'OD'
    AND a7.cdname = 'PRICETYPE'
    AND a7.cdval = od.pricetype
    AND a8.cdtype = 'OD'
    AND a8.cdname = 'REJECTCD'
    AND a8.cdval = od.rejectcd
    AND a9.cdtype = 'SY'
    AND a9.cdname = 'YESNO'
    AND a9.cdval = od.deltd
    AND NVL (tlg.tlid, '____') = mk.tlid
    AND NVL (tlg.offid, '____') = ofc.tlid
    AND od.txdate = tlg.txdate(+)
    AND od.txnum = tlg.txnum(+)
    AND a1.cdname = 'ORSTATUS'
    AND (CASE
            WHEN (tlg.offid IS NULL) AND od.via <> 'W'
            AND tlg.tltxcd NOT IN
                   ('8874',
                    '8875',
                    '8876',
                    '8877',
                    '8882',
                    '8883',
                    '8884',
                    '8885',
                    '8890',
                    '8891',
                    '8886'
                   )
               THEN '9'
            WHEN (tlg.offid IS NOT NULL) AND tlg.txstatus = '5'
               THEN '6'
            WHEN (tlg.offid IS NOT NULL) AND tlg.txstatus = '8'
               THEN '0'
            ELSE od.orstatus
         END
        ) = a1.cdval)
/
