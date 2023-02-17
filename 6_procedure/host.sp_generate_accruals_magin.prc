SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_generate_accruals_magin
(  pv_txdate in VARCHAR,
   pv_errmsg out VARCHAR ) IS

  pkgctx   plog.log_ctx;
  logrow   tlogdebug%ROWTYPE;

v_txdate                         DATE;
v_txnum                          VARCHAR2(10);
v_busdate                        DATE;
v_custid                         VARCHAR2(10);
v_afacctno                       VARCHAR2(10);
v_custodycd                      VARCHAR2(10);
v_TLTXCD                         VARCHAR2(10);
v_POSTING_CODE                   VARCHAR2(50);
V_BANKID                        VARCHAR2(10);
v_BRID                           VARCHAR2(10);
v_GLGRP                          VARCHAR2(50);
v_AMOUNT                         NUMBER ;
v_BRDEBITACCT                    VARCHAR2(50);
v_BRCREDITACCT                   VARCHAR2(50);
v_BRNOTES                        VARCHAR2(500);
v_BRGRPTYPE                        VARCHAR2(10);
v_HODEBITACCT                    VARCHAR2(50);
v_HOCREDITACCT                   VARCHAR2(50);
v_HONOTES                        VARCHAR2(500);
v_HOGRPTYPE                      VARCHAR2(10);
v_REFCUSTOMER                    VARCHAR2(50);
v_currdate                       DATE ;
v_amtexp                          VARCHAR2(100);
v_pos_amtexp                      VARCHAR2(100);
v_expression                      VARCHAR2(100);
v_evaluator                       VARCHAR2(100);
v_ruBrid                          VARCHAR2(100);
v_actype                          VARCHAR2(100);
v_defbrid                         VARCHAR2(100);
v_code                            VARCHAR2(100);
V_gltypesubcd                     VARCHAR2(100);
V_glcusttype                      VARCHAR2(100);
V_SYMBOL                          VARCHAR2(100);
v_bridgl                          VARCHAR2(100);
V_typebridgl                       VARCHAR2(100);
v_class                            VARCHAR2(100);
v_fullname                          VARCHAR2(100);
v_autoid_glrule                VARCHAR2(100);
v_refci                        VARCHAR2(100);
v_catype                        VARCHAR2(100);
v_sumfeamtadv                  number ;
V_feeamtadv                    NUMBER ;
v_groupid                      VARCHAR2(100);
V_dueno                        VARCHAR2(100);
v_cfbrid                       VARCHAR2(100);
V_FEE_POSTING_CODE                    VARCHAR2(100);
pv_txnum                        VARCHAR2(100);
v_FAMOUNT                      NUMBER ;
v_TAMOUNT                      NUMBER ;
tpv_txnum                      VARCHAR2(100);
--Khai bao con tro
cursor v_cursor_txmapglrules (v_tltxcd varchar2) is
select  * from txmapglrules
where tltxcd =v_tltxcd;

v_txmapglrules_row v_cursor_txmapglrules%ROWTYPE;

cursor v_cursor_lninttran (v_txdate varchar2) is
SELECT  lm.trfacctno,sum(TRUNC(lntr.accrualsamt)) intamt, max(lnschdid) lnschdid,frdate,todate
FROM lninttran lntr,lnmast lm
WHERE lm.acctno = lntr.acctno
AND frdate = to_date(v_txdate,'dd/mm/yyyy')
GROUP BY  lm.trfacctno,frdate,todate ;

v_lninttran_row v_cursor_lninttran%ROWTYPE;

BEGIN

v_txdate:= to_date( pv_txdate,'dd/mm/yyyy');

select to_date(varvalue,'dd/mm/yyyy') into v_currdate from sysvar where varname = 'CURRDATE';


--thong tin giao dich
 v_tltxcd := '5580';

--xac dinh but toan
 OPEN v_cursor_lninttran(pv_txdate);
      LOOP
        pv_errmsg:='Begin';
       FETCH v_cursor_lninttran INTO v_lninttran_row;
       EXIT WHEN v_cursor_lninttran%NOTFOUND;


--xac dinh so tieu khoan
v_afacctno:=v_lninttran_row.trfacctno;
pv_txnum:= lpad (v_lninttran_row.lnschdid,10,'0');

v_AMOUNT:= round( v_lninttran_row.intamt);
V_BANKID:='-';
V_BANKID :='-';
-- thong tin khach hang

 IF to_char(v_lninttran_row.frdate,'MM') <>to_char(v_lninttran_row.todate,'MM') and v_lninttran_row.todate-     v_lninttran_row.frdate>1   THEN
 v_FAMOUNT:= TRUNC( v_lninttran_row.intamt*(LAST_DAY(v_lninttran_row.frdate) -v_lninttran_row.frdate+1)/ (v_lninttran_row.todate-v_lninttran_row.frdate)   );
 v_TAMOUNT:= v_AMOUNT -v_FAMOUNT;
 tpv_txnum:= lpad (v_lninttran_row.lnschdid,10,'9');
 delete from gljournal where txdate=v_lninttran_row.todate AND TLTXCD ='5580' AND SUBSTR(TXNUM,1,1)='9' AND afacctno = v_lninttran_row.trfacctno;
 delete from gljournal where txdate=to_date(pv_txdate,'dd/mm/rrrr') AND TLTXCD ='5580' AND SUBSTR(TXNUM,1,1)='0' AND afacctno = v_lninttran_row.trfacctno;
 ELSE
 delete from gljournal where txdate=to_date(pv_txdate,'dd/mm/rrrr') AND TLTXCD ='5580' AND SUBSTR(TXNUM,1,1)='0' AND afacctno = v_lninttran_row.trfacctno;
 END IF ;

begin


/*select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
,cf.custtype, CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT','BID') THEN brgrp.glmapid ELSE brcf.glmapid END glmapid ,fullname,cf.class,
brcf.glmapid||CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT','BID') THEN tlgroups.shortname ELSE '' END   CFBRID
into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
from cfmast cf, afmast af,aftype,brgrp ,tlgroups, brgrp brcf
where cf.custid = af.custid
and af.actype = aftype.actype
and cf.brid = brcf.brid
and cf.careby = tlgroups.grpid
and tlgroups.bridgl =brgrp.brid(+)
and af.acctno = v_afacctno;*/
select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
,cf.custtype, NVL( brgrp.glmapid , brcf.glmapid) glmapid ,fullname,cf.class,
brcf.glmapid||GRPGLMAP.glname   CFBRID
into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
from cfmast cf, afmast af,aftype,brgrp ,(SELECT * FROM GRPGLMAP WHERE status ='A') GRPGLMAP, brgrp brcf
where cf.custid = af.custid
and af.actype = aftype.actype
and cf.brid = brcf.brid
and cf.careby = GRPGLMAP.grpid(+)
and GRPGLMAP.bridgl =brgrp.brid(+)
and af.acctno = v_afacctno
;



exception  when others then
v_afacctno :='';
end ;


--xac dinh but toan
 OPEN v_cursor_txmapglrules(v_tltxcd);
      LOOP
        pv_errmsg:='Begin';
       FETCH v_cursor_txmapglrules INTO v_txmapglrules_row;
       EXIT WHEN v_cursor_txmapglrules%NOTFOUND;

v_defbrid := v_txmapglrules_row.defbrid;
v_amtexp := v_txmapglrules_row.amtexp;
v_posting_code := v_txmapglrules_row.POSTING_CODE;


-- XAC DINH BUT TOAN THEO BRID GLTYPESUBCD GLCUSTTYPE
BEGIN
    -- XAC DINH BUT TOAN THEO BRID GLTYPESUBCD GLCUSTTYPE
SELECT max(brid||gltypesubcd||glcusttype||BANKID||class||GLGRP) into v_code from glrules
    where posting_code =v_posting_code
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = V_BANKID
     AND decode( GLGRP,'ALL', v_actype,GLGRP) = v_actype
    and class = v_class
    ;



    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =v_posting_code and  brid||gltypesubcd||glcusttype||BANKID||class||GLGRP  = v_code;

 plog.debug(pkgctx, '10_GL v_autoid_glrule1:'||v_autoid_glrule);

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =v_posting_code AND autoid = v_autoid_glrule;

EXCEPTION
    WHEN OTHERS THEN
v_BRDEBITACCT:='';
v_BRCREDITACCT:='';
END ;


IF LENGTH (v_BRDEBITACCT)+ LENGTH (v_BRCREDITACCT)>0 THEN

--gan gia tri
--tinh gia tri amount




   if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;



   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);



IF v_AMOUNT>0 THEN



IF to_char(v_lninttran_row.frdate,'MM') <>to_char(v_lninttran_row.todate,'MM') and v_lninttran_row.todate-     v_lninttran_row.frdate>1  THEN
INSERT INTO gljournal
(ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid,SYMBOL)
VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,v_FAMOUNT,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid,V_SYMBOL );

INSERT INTO gljournal
(ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid,SYMBOL)
VALUES (seq_gljournal.NEXTVAL, v_lninttran_row.todate,Tpv_txnum ,v_lninttran_row.todate,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,v_TAMOUNT,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid,V_SYMBOL );

ELSE
INSERT INTO gljournal
(ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid,SYMBOL)
VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,v_AMOUNT,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid,V_SYMBOL );
END IF ;

END IF ;

END IF;

END LOOP;
  CLOSE v_cursor_txmapglrules;
END LOOP;

 CLOSE v_cursor_lninttran;
---------------------------------------------------------------------------

--  dbms_output.put_line('End');
EXCEPTION
  WHEN OTHERS THEN

        plog.error (pkgctx, SQLERRM);
  return;

END;

 
 
 
 
/
