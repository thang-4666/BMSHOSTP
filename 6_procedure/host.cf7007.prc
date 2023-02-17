SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7007" (
   pv_refcursor   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   maker          IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2,
   action         IN       VARCHAR2,
   table_name     IN       VARCHAR2,
   table_key      IN       VARCHAR2,
   checker        IN       VARCHAR2
 )
IS
--created by CHAUNH at 19/10/2011
   l_maker VARCHAR2(4);
   l_checker VARCHAR2(4);
   l_table_name VARCHAR2(20);
   l_action VARCHAR2(20);
   l_table_key VARCHAR2(50);
BEGIN

   IF (maker <> 'ALL') THEN
      l_maker := maker;
   ELSE
      l_maker := '%%';
   END IF;

   IF (action <> 'ALL') THEN
      l_action := action;
   ELSE
      l_action := '%%';
   END IF;

   IF (table_name <> 'ALL') THEN
      l_table_name := table_name;
   ELSE
      l_table_name := '%%';
   END IF;

   IF (table_key <> 'ALL') THEN
      l_table_key := '%'||table_key||'%';
   ELSE
      l_table_key := '%%';
   END IF;

   IF (checker <> 'ALL')
   THEN
      l_checker := checker;
   ELSE
      l_checker := '%%';
   END IF;


OPEN pv_refcursor
  FOR
    SELECT case when log.child_table_name is not null then log.table_name ||'.'||log.child_table_name else log.table_name end table_name,
            case when log.child_table_name is not null then log.record_key ||' AND '||log.child_record_key else log.record_key end record_key,
            tl.tlname maker_id,
            log.maker_dt,
            log.approve_rqd,
            tl2.tlname approve_id,
            log.approve_dt,
            log.mod_num,
            log.column_name,
            log.from_value,
            log.to_value,
            (case when log.action_flag='ADD' then 'Thêm mới' else 'Sửa' end) action_flag,
            log.child_table_name,
            log.child_record_key
     FROM Maintain_log Log,  tlprofiles tl, tlprofiles tl2
     WHERE  log.maker_id = tl.tlid(+)
           AND  log.approve_id = tl2.tlid(+)
           AND TO_DATE(log.approve_dt,'DD/MM/RRRR') >= TO_DATE(f_date,'DD/MM/RRRR')
           AND TO_DATE(log.approve_dt,'DD/MM/RRRR') <= TO_DATE(t_date,'DD/MM/RRRR')
           AND log.maker_id like l_maker
           AND log.approve_id like l_checker
           AND ( log.table_name like l_table_name
                 OR log.child_table_name like l_table_name
               )
           AND log.record_key like l_table_key
           AND log.action_flag like l_action

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
