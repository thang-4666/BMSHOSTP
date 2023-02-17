SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_RM_TCDT_CHECKWORKINGTIME
(RESULT)
BEQUEATH DEFINER
AS 
select case when (to_char(sysdate,'hh24:mi:ss') >= st.varvalue and to_char(sysdate,'hh24:mi:ss') <= ot.varvalue
and   cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS')='1'
 )
then 0 else 1 end result from sysvar st, sysvar ot
where st.grname ='SYSTEM' and st.varname ='TCDTSTARTTIME'
and ot.grname ='SYSTEM' and ot.varname ='TCDTOFFTIME'
/
