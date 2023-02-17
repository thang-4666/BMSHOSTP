SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_CHECKPTREPO_SUBMIT2" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_REFORDERID in varchar2,pv_FORM in varchar2)
is
begin

    if pv_form='NML' OR pv_form='PT' then
        OPEN PV_REFCURSOR FOR
        SELECT  tb.STATUS,OD.ORDERID, NVL(OD2.DELTD,' ') DELTD,
            NVL(OD2.EXECQTTY,-1) EXECQTTY, NVL(OD2.CANCELQTTY ,-1) CANCELQTTY ,
            nvl(od2.orderqtty,-1) orderqtty2,
            NVL(OD2.ADJUSTQTTY ,-1) ADJUSTQTTY, NVL(OD2.REJECTQTTY ,-1) REJECTQTTY, NVL(OD2.ORSTATUS ,'') ORSTATUS,
            NVL(OD3.EXECQTTY,-1) G_EXECQTTY, NVL(OD3.CANCELQTTY ,-1) G_CANCELQTTY ,
            NVL(OD4.EXECQTTY,-1) G_EXECQTTY2, NVL(OD4.CANCELQTTY ,-1) G_CANCELQTTY2 ,
            TB.orderqtty, OD.GRPORDER,
            NVL(OD2.GRPORDER,' ') GRPORDER2
            FROM VW_ODMAST_ALL OD,  TBL_ODREPO TB,
            VW_ODMAST_ALL OD2,
            (SELECT SUM (orderqtty) orderqtty,sum(execqtty) execqtty,
            sum(cancelqtty) cancelqtty ,voucher
            FROM VW_ODMAST_ALL WHERE LENGTH(voucher) =16 AND deltd='N' GROUP BY voucher) OD3,
            (SELECT SUM (orderqtty) orderqtty,sum(execqtty) execqtty,
            sum(cancelqtty) cancelqtty ,voucher
         FROM VW_ODMAST_ALL WHERE LENGTH(voucher) =16 AND deltd='N' GROUP BY voucher) OD4
         WHERE OD.ORDERID = TB.ORDERID   AND TB.ORDERID = pv_REFORDERID
         AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
         AND (CASE WHEN OD.GRPORDER ='Y' THEN 0 ELSE  OD.CANCELQTTY END )=0
         AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N'
         AND TB.ORDERID2 = OD2.ORDERID (+)
         AND tb.orderid =  OD3.voucher (+)
         AND tb.orderid2 =  OD4.voucher (+);
    ELSIF pv_form='1F' then
        OPEN PV_REFCURSOR FOR
        SELECT TB.STATUS,OD.ORDERID, NVL(OD2.DELTD,'N') DELTD, NVL(OD2.EXECQTTY,0) EXECQTTY, OD.GRPORDER,
                NVL(OD2.CANCELQTTY ,0) CANCELQTTY,
                nvl(od2.orderqtty,-1) orderqtty2,
                NVL(OD2.ADJUSTQTTY ,-1) ADJUSTQTTY, NVL(OD2.REJECTQTTY ,-1) REJECTQTTY, NVL(OD2.ORSTATUS ,'') ORSTATUS
                FROM VW_ODMAST_ALL OD,  TBL_ODREPO TB, VW_ODMAST_ALL OD2
                WHERE OD.DELTD='N' AND OD.ORDERID = TB.ORDERID
                AND TB.ORDERID = pv_REFORDERID AND OD.EXECQTTY >0
                AND OD.CANCELQTTY=0
                AND TB.ORDERID2 = OD2.ORDERID (+) ;
    ELSIF pv_form='GRP' then
        OPEN PV_REFCURSOR FOR
        SELECT  tb.STATUS,OD.ORDERID, NVL(OD2.DELTD,' ') DELTD,
                   NVL(OD2.EXECQTTY,-1) EXECQTTY, NVL(OD2.CANCELQTTY ,-1) CANCELQTTY ,
                  nvl(od2.orderqtty,-1) orderqtty2,
                  NVL(OD2.ADJUSTQTTY ,-1) ADJUSTQTTY, NVL(OD2.REJECTQTTY ,-1) REJECTQTTY, NVL(OD2.ORSTATUS ,'') ORSTATUS,
                   NVL(OD3.EXECQTTY,-1) G_EXECQTTY, NVL(OD3.CANCELQTTY ,-1) G_CANCELQTTY ,
                   NVL(OD4.EXECQTTY,-1) G_EXECQTTY2, NVL(OD4.CANCELQTTY ,-1) G_CANCELQTTY2 ,
                   TB.orderqtty, OD.GRPORDER,
                    NVL(OD2.GRPORDER,' ') GRPORDER2
                FROM VW_ODMAST_ALL OD,  TBL_ODREPO TB,
                VW_ODMAST_ALL OD2,
                 (SELECT SUM (orderqtty) orderqtty,sum(execqtty) execqtty,
                sum(cancelqtty) cancelqtty ,voucher
                FROM VW_ODMAST_ALL WHERE LENGTH(voucher) =16 AND deltd='N' GROUP BY voucher) OD3,
                (SELECT SUM (orderqtty) orderqtty,sum(execqtty) execqtty,
                sum(cancelqtty) cancelqtty ,voucher
                 FROM VW_ODMAST_ALL WHERE LENGTH(voucher) =16 AND deltd='N' GROUP BY voucher) OD4
                 WHERE OD.ORDERID = TB.ORDERID   AND TB.ORDERID = pv_REFORDERID
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 0 ELSE  OD.CANCELQTTY END )=0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N'
                 AND TB.ORDERID2 = OD2.ORDERID (+)
                 AND tb.orderid =  OD3.voucher (+)
                 AND tb.orderid2 =  OD4.voucher (+);
    END IF;
exception when others then
    return;
end;

 
 
 
 
/
