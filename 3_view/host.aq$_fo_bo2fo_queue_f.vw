SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW AQ$_FO_BO2FO_QUEUE_F
(Q_NAME, ROW_ID, MSGID, CORRID, PRIORITY, 
 STATE, DELAY, EXPIRATION, ENQ_TIME, ENQ_UID, 
 ENQ_TID, DEQ_TIME, DEQ_UID, DEQ_TID, RETRY_COUNT, 
 EXCEPTION_QSCHEMA, EXCEPTION_QUEUE, CSCN, DSCN, CHAIN_NO, 
 LOCAL_ORDER_NO, TIME_MANAGER_INFO, STEP_NO, USER_DATA, SENDER_NAME, 
 SENDER_ADDRESS, SENDER_PROTOCOL, DEQUEUE_MSGID, DELIVERY_MODE, SEQUENCE_NUM, 
 MSG_NUM, QUEUE_ID, USER_PROP)
BEQUEATH DEFINER
AS 
SELECT  /*+ NO_MERGE (qo) USE_NL(qt) */ qt.q_name Q_NAME, qt.rowid ROW_ID, qt.msgid MSGID, qt.corrid CORRID, qt.priority PRIORITY, qt.state STATE, cast(FROM_TZ(qt.delay, '00:00') at time zone sessiontimezone as timestamp) DELAY, qt.expiration EXPIRATION, cast(FROM_TZ(qt.enq_time, '00:00') at time zone sessiontimezone as timestamp) ENQ_TIME, qt.enq_uid ENQ_UID, qt.enq_tid ENQ_TID, cast(FROM_TZ(qt.deq_time, '00:00') at time zone sessiontimezone as timestamp) DEQ_TIME, qt.deq_uid DEQ_UID, qt.deq_tid DEQ_TID, qt.retry_count RETRY_COUNT, qt.exception_qschema EXCEPTION_QSCHEMA, qt.exception_queue EXCEPTION_QUEUE, qt.cscn CSCN, qt.dscn DSCN, qt.chain_no CHAIN_NO, qt.local_order_no LOCAL_ORDER_NO, cast(FROM_TZ(qt.time_manager_info, '00:00') at time zone sessiontimezone as timestamp)   TIME_MANAGER_INFO, qt.step_no STEP_NO, qt.user_data USER_DATA ,qt.sender_name SENDER_NAME, qt.sender_address SENDER_ADDRESS, qt.sender_protocol SENDER_PROTOCOL, qt.dequeue_msgid DEQUEUE_MSGID, 'PERSISTENT' DELIVERY_MODE, 0 SEQUENCE_NUM, 0 MSG_NUM, qo.qid QUEUE_ID, qt.user_prop USER_PROP FROM "BMSHOSTP04"."FO_BO2FO_QUEUE" qt, SYS.ALL_INT_DEQUEUE_QUEUES qo  WHERE qt.q_name = qo.name AND qo.owner = 'BMSHOSTP04' WITH READ ONLY
/
