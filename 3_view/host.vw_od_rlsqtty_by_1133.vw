SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_OD_RLSQTTY_BY_1133
(ORDERID, RLSQTTY)
BEQUEATH DEFINER
AS 
(select cvalue orderid, qtty rlsqtty from         
    (select fld.cvalue, tl.txnum 
    from tllog tl, tllogfld fld
    where tl.txnum= fld.txnum 
    and fld.fldcd='05'
    and tl.deltd <> 'Y' and tl.txstatus ='1'
    and tl.tltxcd ='1133') tl1133,
    (select sum(fld.nvalue) qtty, trim(tl.batchname) batchname, tl.tltxcd 
    from tllog tl,tllogfld fld 
    where  fld.fldcd='10'
    and tl.txnum = fld.txnum 
    and tltxcd ='2643'
    and tl.deltd <> 'Y' and  tl.txstatus ='1'
    group by trim(tl.batchname), tl.tltxcd ) tl2643
    where tl1133.txnum = tl2643.batchname
)
/
