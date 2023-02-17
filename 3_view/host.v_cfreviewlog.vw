SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CFREVIEWLOG
(CUSTID, CUSTODYCD, FULLNAME, CFTYPE, CFTYPE_DESC, 
 TRADEVALUE, NAV, FEEAMT, FINREVENUE, DFREVENUE, 
 ADREVENUE, NUMOVERDEAL, CALLDAYS, OVERDUEDAY, ODAMT, 
 STATUS, LOGDAYS, NEWCFTYPE, NEWCFTYPE_DESC, RESULT, 
 RESULT_DESC)
BEQUEATH DEFINER
AS 
select cf.custid,cf.custodycd,cf.fullname,
       cfl.cftype,
       ocft.typename cftype_desc,
        cfl.tradevalue, -- gia tri giao dich
        cfl.nav,-- NAV
        cfl.feeamt,-- phi giao dich
        cfl.finrevenue,  --- doanh thu margin
        cfl.DFREVENUE , -- doanh thu cam co
        cfl.ADREVENUE, -- doanh thu UTTB
        cfl.numoverdeal, -- so mon vay qua han
        cfl.calldays,-- so ngay vi pham ti ly
        cfl.OVERDUEDAY, -- so ngay qua han
        cfl.odamt,
        cfl.status,
        cfl.logdays,
        cfl.newcftype,
        ncft.typename newcftype_desc,
        cfl.result,
        case  
            when cfl.result = 0 then 'Giu hang'  
            when cfl.result = 1 then 'Len hang'
            else 'Xuong hang'
        end result_desc 
 from cfreviewlog cfl, cfmast cf , cftype ocft, cftype ncft
 where cfl.custid=cf.custid and cfl.status='C'
       and cfl.cftype=ocft.actype
       and cfl.newcftype=ncft.actype
/
