SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ODMAST
(ORDERID, REFORDERID, TRADEPLACE, AFACCTNO, CUSTODYCD, 
 SYMBOL, ORSTATUS, EDSTATUS, ACTYPE, VIA, 
 MAKER, MAKETIME, SENDTIME, TIMETYPE, TXNUM, 
 TXDATE, EXPDATE, BRATIO, EXECTYPE, NORK, 
 MATCHTYPE, CLEARDAY, CLEARCD, PRICETYPE, QUOTEPRICE, 
 STOPPRICE, LIMITPRICE, ORDERQTTY, REMAINQTTY, EXECQTTY, 
 STANDQTTY, CANCELQTTY, ADJUSTQTTY, REJECTQTTY, REJECTCD, 
 EXPRICE, EXQTTY, DELTD, FOACCTNO, PUTTYPE, 
 CONTRAORDERID, CONTRAFRM, DFACCTNO, MAKERNAME, ISDISPOSAL, 
 SECUREDAMT, QUOTEQTTY, CONFIRMED, PTDEAL, MNEMONIC)
BEQUEATH DEFINER
AS 
SELECT vw."ORDERID",vw."REFORDERID",vw."TRADEPLACE",vw."AFACCTNO",vw."CUSTODYCD",vw."SYMBOL",vw."ORSTATUS",
vw."EDSTATUS",vw."ACTYPE",vw."VIA",vw.tlname MAKER,vw."MAKETIME",vw."SENDTIME",vw."TIMETYPE",
vw."TXNUM",vw."TXDATE",vw."EXPDATE",vw."BRATIO",vw."EXECTYPE",vw."NORK",vw."MATCHTYPE",vw."CLEARDAY",vw."CLEARCD",
vw."PRICETYPE",vw."QUOTEPRICE",vw."STOPPRICE",vw."LIMITPRICE",vw."ORDERQTTY",vw."REMAINQTTY",vw."EXECQTTY",
vw."STANDQTTY",vw."CANCELQTTY",vw."ADJUSTQTTY",vw."REJECTQTTY",vw."REJECTCD",vw."EXPRICE",vw."EXQTTY",vw."DELTD",
vw."FOACCTNO",vw."PUTTYPE",vw."CONTRAORDERID",vw."CONTRAFRM",vw."DFACCTNO",mk.tlname MAKERNAME,
VW.isdisposal, securedamt, vw.quoteqtty, vw.confirmed, vw.ptdeal, vw.mnemonic
FROM
(
SELECT od.orderid orderid, od.reforderid, a0.cdcontent tradeplace,
           od.afacctno,
           cf.custodycd,
        se.symbol symbol,
        case when  od.cancelstatus ='N' then a1.cdcontent else a12.cdcontent end orstatus,
        a10.cdcontent edstatus,
        ot.typename actype, a2.cdcontent via, mk.tlid maker,mk.tlname,
        od.txtime maketime,
        --NVL (tlg.offtime, '____') apprtime,
        NVL (od.sendtime, '____') sendtime,
        a3.cdcontent timetype, od.txnum, od.txdate, od.expdate, od.bratio,
        a4.cdcontent exectype, od.nork, a5.cdcontent matchtype, od.clearday,
        a6.cdcontent clearcd, a7.cdcontent pricetype, od.quoteprice,
        od.stopprice, od.limitprice, od.orderqtty, od.remainqtty, od.execqtty,
        od.standqtty, od.cancelqtty, od.adjustqtty, od.rejectqtty,
        a8.cdcontent rejectcd, od.exprice, od.exqtty, a9.cdcontent deltd,
        od.foacctno, od.puttype, od.contraorderid,
        od.contrafrm,dfacctno, A11.cdcontent isdisposal, securedamt,
        od.quoteqtty, od.confirmed, od.ptdeal, aft.mnemonic
   FROM afmast af, cfmast cf, sbsecurities se, odtype ot, aftype aft,
        allcode a0, allcode a1, allcode a2, allcode a3, allcode a4, allcode a5,
        allcode a6, allcode a7, allcode a8, allcode a9, allcode a10,allcode a11,allcode a12,
        (SELECT od.*, ood.txtime sendtime, ood.oodstatus
           FROM ODMAST od, vw_ood_all  OOD
          WHERE od.orderid = ood.orgorderid) od,
        (SELECT tlid, tlname FROM tlprofiles
         UNION ALL
         SELECT '____' tlid, '____' tlname FROM DUAL
         UNION ALL
         SELECT 'ONL' tlid, 'ONLINE' tlname FROM DUAL
         ) mk--,
  WHERE od.afacctno = af.acctno and af.actype = aft.actype
    AND af.custid = cf.custid
    AND od.codeid = se.codeid
    AND od.actype = ot.actype
    AND a10.cdtype = 'OD' AND a10.cdname = 'EDSTATUS' AND a10.cdval = od.edstatus
    AND a0.cdtype = 'OD' AND a0.cdname = 'TRADEPLACE' AND a0.cdval = se.tradeplace
    AND a2.cdtype = 'OD' AND a2.cdname = 'VIA' AND a2.cdval = od.via
    AND a3.cdtype = 'OD' AND a3.cdname = 'TIMETYPE' AND a3.cdval = od.timetype
    AND a4.cdtype = 'OD' AND a4.cdname = 'EXECTYPE' AND a4.cdval = od.exectype
    AND a5.cdtype = 'OD' AND a5.cdname = 'MATCHTYPE' AND a5.cdval = od.matchtype
    AND a6.cdtype = 'OD' AND a6.cdname = 'CLEARCD' AND a6.cdval = od.clearcd
    AND a7.cdtype = 'OD' AND a7.cdname = 'PRICETYPE' AND a7.cdval = od.pricetype
    AND a8.cdtype = 'OD' AND a8.cdname = 'REJECTCD' AND a8.cdval = od.rejectcd
    AND a9.cdtype = 'SY' AND a9.cdname = 'YESNO' AND a9.cdval = od.deltd
    AND A11.CDTYPE = 'SY' AND A11.CDNAME = 'YESNO' AND A11.CDVAL= OD.isdisposal
    and od.tlid = mk.tlid
    AND a1.cdname = 'ORSTATUS'
    AND a12.cdtype = 'OD' AND a12.cdname = 'CANCELSTATUS' and a12.cdval=OD.cancelstatus
     AND od.orstatus= a1.cdval
) vw,
(SELECT tlid, tlname FROM tlprofiles
         UNION ALL
         SELECT '____' tlid, '____' tlname FROM DUAL
         UNION ALL
         SELECT 'ONL' tlid, 'ONLINE' tlname FROM DUAL
         ) mk WHERE vw.maker=mk.tlid
/
