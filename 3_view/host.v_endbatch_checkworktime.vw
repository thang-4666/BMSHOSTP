SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ENDBATCH_CHECKWORKTIME
(RESULT)
BEQUEATH DEFINER
AS 
select case when to_char(sysdate,'hh24:mi:ss') >= st.varvalue then 0 else 1 end result
FROM sysvar st
where st.grname ='SYSTEM' and st.varname ='ENDBATCHTIME'
/
