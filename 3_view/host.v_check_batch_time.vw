SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECK_BATCH_TIME
(RESULT)
BEQUEATH DEFINER
AS 
select case when (to_char(sysdate,'hh24:mi:ss') >= st.varvalue and to_char(sysdate,'hh24:mi:ss') <= ot.varvalue
and   cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS')='0'
 )
then 0 else 1 end result from sysvar st, sysvar ot
where st.grname ='SYSTEM' and st.varname ='BATCHSTARTTIME'
and ot.grname ='SYSTEM' and ot.varname ='BATCHOFFTIME'
/
