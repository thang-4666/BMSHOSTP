SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getcrbtrflog_createuser(pv_CRBID varchar2) return varchar2 
is
    v_refreqid number;
    v_txnum varchar2(10);
    v_txdate date;
    v_tlid varchar2(10);
begin
    select nvl(max(refreqid),-1), max(nvl(mst.tlid,'0000')) into v_refreqid,v_tlid from CRBTRFLOG mst, crbtrflogdtl dtl
    where MST.REFBANK=DTL.BANKCODE AND MST.TRFCODE=DTL.TRFCODE AND MST.TXDATE=DTL.TXDATE 
    AND MST.VERSION=DTL.VERSION AND mst.autoid = pv_CRBID;
    select objkey, txdate into v_txnum,v_txdate  from crbtxreq where reqid=v_refreqid;
    select nvl(tlid,offid) into v_tlid from vw_tllog_all where txnum = v_txnum and txdate = v_txdate;
    --select tlname into v_tlid from tlprofiles where tlid = v_tlid;
    return v_tlid;
exception when others then 
    --select tlname into v_tlid from tlprofiles where tlid = v_tlid;
    return nvl(v_tlid,'0000');
end; 
 
 
 
 
 
 
/
