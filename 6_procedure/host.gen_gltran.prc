SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE gen_gltran (l_tltxcd varchar2,l_txdate  VARCHAR2) IS
a VARCHAR2(1000);
v_tltxcd varchar (30);
v_custid varchar (30);
  pkgctx   plog.log_ctx;
BEGIN

 if UPPER(l_tltxcd )='ALL' THEN
    v_tltxcd:='%';
    ELSE
    v_tltxcd:=l_tltxcd;
    END IF;


    delete gljournal where txdate =to_date(l_txdate,'DD/MM/YYYY') and tltxcd <>'5580' and INSTR(TLTXCD, decode( UPPER(l_tltxcd ),'ALL',TLTXCD,l_tltxcd))>0;
    --I:=0;
 plog.error(pkgctx, 'NAMNT00_GL :'||l_txdate);
 plog.error(pkgctx, 'NAMNT01_GL :'||to_char( getcurrdate(),'dd/mm/yyyy'));

IF  UPPER(l_tltxcd )='ALL' OR l_tltxcd ='5580' THEN
 sp_generate_accruals_magin(l_txdate,a);
 END IF;


if l_txdate <> to_char( getcurrdate(),'dd/mm/yyyy') then
  plog.error(pkgctx, 'NAMNT02_GL :'||'sp_generate_gljournal');
   FOR REC IN
            (
             select to_char(txdate,'dd/mm/yyyy')  txdate , txnum  from vw_tllog_all
             where   txdate = to_date(l_txdate,'dd/mm/yyyy') and tltxcd like v_tltxcd
             and tltxcd in (select tltxcd from txmapglrules)
             AND txstatus in('3','7','4','1')
            )
        LOOP
           sp_generate_gljournal(REC.TXDATE,REC.TXNUM,a);
    END LOOP;


else
  plog.error(pkgctx, 'NAMNT03_GL :'||'sp_generate_gljournal_inday');
   FOR REC IN
            (
             select to_char(txdate,'dd/mm/yyyy')  txdate , txnum  from tllog
             where   txdate = to_date(l_txdate,'dd/mm/yyyy') and tltxcd like v_tltxcd
             and tltxcd in (select tltxcd from txmapglrules)
             and deltd <>'Y'
             AND txstatus in('3','7','4','1')
            )
        LOOP
           sp_generate_gljournal_inday(REC.TXDATE,REC.TXNUM,a);
    END LOOP;

end if ;


 EXCEPTION
  WHEN OTHERS THEN
  return;

  END ;

 
 
 
 
/
