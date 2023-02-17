SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_TRANFER_DATAS_EBS"
IS
begin
null;
end;
/*
    txdate  varchar2(20);

BEGIN

    SELECT VARVALUE INTO txdate FROM SYSVAR
    WHERE GRNAME='SYSTEM'
    AND VARNAME='PREVDATE';
    SP_GENERATE_EXPORTGL(txdate,'%'); -- Lay tat ca cac loai giao dich
    commit;
    SP_GENERATE_VOUCHERNO(txdate,'%');
    commit;
    sp_generate_trf2ebs(txdate); -- Day gd sang BOSC_GL cua database EBS
    insert into bosc_gl_hist@linkebs select * from bosc_gl@linkebs where post='Y';
    commit;
    delete bosc_gl@linkebs where post='Y';
    commit;
    SBS_BOSC_TO_GL.TRANSFER_TO_GL_AGAIN@LINKEBS;
    SBS_BOSC_TO_GL.TRANSFER_TO_GL@LINKEBS;
END;*/

 
 
 
 
/
