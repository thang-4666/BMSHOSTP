SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_OBJECT_BASEDONBODY(p_obj_type IN CHAR, p_obj_name IN VARCHAR2, p_inputs VARCHAR2) RETURN NUMBER
IS
   return_val NUMBER := 0;
BEGIN
   --VIEW
   IF p_obj_type='V' THEN
      FOR x IN (SELECT text valtext FROM user_views WHERE view_name =p_obj_name) 
      LOOP
          IF ( x.valtext LIKE p_inputs ) THEN
             return_val :=1;
          END IF;
      END LOOP;
   END IF;
   --TRIGGERS
   IF p_obj_type='T' THEN
      FOR x IN (SELECT trigger_body valtext FROM user_triggers WHERE trigger_name =p_obj_name) 
      LOOP
          IF ( x.valtext LIKE p_inputs ) THEN
             return_val :=1;
          END IF;
      END LOOP;
   END IF;
   --RETURN
   RETURN return_val;
EXCEPTION
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
