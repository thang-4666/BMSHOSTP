SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE delete_tltx (p_tltxcd IN VARCHAR2,p_type in varchar2)
  IS
v_strDrop varchar2(100);
v_modcode varchar2(100);
BEGIN

case p_type
when 'T'  THEN -- giao dich
    begin
        select modcode into v_modcode
        from fldmaster where objname =p_tltxcd and rownum=1;

        --clear noi dung trong tltx
        delete from tltx where tltxcd =p_tltxcd;
        delete from fldmaster where objname =p_tltxcd;
        delete from rptmaster where rptid =v_modcode||p_tltxcd and cmdtype='V';
        delete from search where searchcode =p_tltxcd;
        delete from searchfld where searchcode =p_tltxcd;
        v_strDrop:= ' DROP PACKAGE TXPKS_#'||p_tltxcd||'EX'  ;
        EXECUTE IMMEDIATE v_strDrop;

        v_strDrop:= ' DROP PACKAGE TXPKS_#'||p_tltxcd  ;
        EXECUTE IMMEDIATE v_strDrop;
    end;
when 'V' THEN --- view
       begin
          delete from rptmaster where rptid =substr(p_tltxcd,2) and cmdtype='V';
         delete from search where searchcode =  substr(p_tltxcd,2) ;
        delete from searchfld where searchcode =  substr(p_tltxcd,2) ;
       end;
when 'R' THEN --- report
       begin
          delete from rptmaster where rptid =substr(p_tltxcd,2) and cmdtype='R';
          delete from rptfields where objname =  substr(p_tltxcd,2) ;
       end;
when 'M' then  --- menu
      begin
        select modcode||'.'||objname into v_modcode
        from cmdmenu where cmdid =p_tltxcd and rownum=1;

        delete from cmdmenu where cmdid = p_tltxcd;
        delete from fldmaster where objname =v_modcode;
        delete from grmaster where objname =v_modcode;
        delete from objmaster where objname =v_modcode;
        commit;
      end;
end case;

commit;

EXCEPTION
    WHEN others THEN
    Rollback;

END;
 
 
 
 
/
