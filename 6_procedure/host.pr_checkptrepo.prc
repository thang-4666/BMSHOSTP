SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_CHECKPTREPO" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_REFORDERID in varchar2,pv_form in varchar2)
is
begin
    if pv_form='NML' then
        OPEN PV_REFCURSOR FOR
        select tb.CUSTODYCD,tb.QUOTEPRICE,tb.CODEID,tb.ORDERQTTY,tb.PRICE2,
                 tb.EXPTDATE,tb.EXECTYPE,tb.STATUS,tb.ORDERID2,tb.REF_CUSTODYCD,tb.REF_AFACCTNO, od.CONTRAFIRM, OD.GRPORDER,OD.EXECQTTY
                 from tbl_odrepo TB, VW_ODMAST_ALL OD  where   tb.orderid = od.orderid and tb.orderid= pv_REFORDERID
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N';
    ELSIF pv_form='PT' then
        OPEN PV_REFCURSOR FOR
        select tb.CUSTODYCD,tb.QUOTEPRICE,tb.CODEID,tb.ORDERQTTY,tb.PRICE2,
                 tb.EXPTDATE,tb.EXECTYPE,tb.STATUS,tb.ORDERID2,tb.REF_CUSTODYCD,tb.REF_AFACCTNO, od.CONTRAFIRM, OD.GRPORDER,OD.EXECQTTY
                 from tbl_odrepo TB, VW_ODMAST_ALL OD  where   tb.orderid = od.orderid and tb.orderid= pv_REFORDERID
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N' ;
    ELSIF pv_form='1F' then
        OPEN PV_REFCURSOR FOR
        select tb.CUSTODYCD,tb.QUOTEPRICE,tb.CODEID,tb.ORDERQTTY,tb.PRICE2,
                 tb.EXPTDATE,tb.EXECTYPE,tb.STATUS,tb.ORDERID2,tb.REF_CUSTODYCD,tb.REF_AFACCTNO, od.CONTRAFIRM, OD.GRPORDER,OD.EXECQTTY
                 from tbl_odrepo TB, VW_ODMAST_ALL OD  where   tb.orderid = od.orderid and tb.orderid= pv_REFORDERID
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N';
    ELSIF pv_form='GRP' then
        OPEN PV_REFCURSOR FOR
        select tb.CUSTODYCD,tb.QUOTEPRICE,tb.CODEID,tb.ORDERQTTY,tb.PRICE2,
                 tb.EXPTDATE,tb.EXECTYPE,tb.STATUS,tb.ORDERID2,tb.REF_CUSTODYCD,tb.REF_AFACCTNO, od.CONTRAFIRM, OD.GRPORDER,OD.EXECQTTY
                 from tbl_odrepo TB, VW_ODMAST_ALL OD  where   tb.orderid = od.orderid and tb.orderid= pv_REFORDERID
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 1 ELSE  OD.EXECQTTY END ) >0
                 AND (CASE WHEN OD.GRPORDER ='Y' THEN 'N' ELSE  OD.DELTD END )= 'N' ;
    END IF;
exception when others then
    return;
end;

 
 
 
 
/
