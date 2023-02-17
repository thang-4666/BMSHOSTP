SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_corebank_acctno( pv_acctno IN VARCHAR2,pv_txdate IN VARCHAR2)
    RETURN VARCHAR2 IS
   v_corebank_CRR varchar2(10);
   v_frcorebank varchar2(10);
   min_autoid number ;
BEGIN
    select corebank into  v_corebank_CRR from afmast where acctno = pv_acctno    ;



for rec in (
             select from_value  from maintain_log
              WHERE column_name ='COREBANK' AND action_flag ='EDIT'
              AND  SUBSTR(child_record_key, INSTR(child_record_key,'''')+1,10) = pv_acctno and maker_dt=
                     (SELECT MIN(maker_dt)
                      FROM maintain_log M WHERE column_name ='COREBANK' AND action_flag ='EDIT'
                      AND  SUBSTR(child_record_key, INSTR(child_record_key,'''')+1,10) = pv_acctno
                      AND  approve_dt >  to_date (pv_txdate,'DD/MM/RRRR')
                       )


)
 loop
 v_frcorebank:=rec.from_value;
 end loop  ;

 v_frcorebank:= NVL(v_frcorebank,v_corebank_CRR);

RETURN v_frcorebank;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
 
 
/
