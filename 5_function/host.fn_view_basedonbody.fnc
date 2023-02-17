SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_VIEW_BASEDONBODY(p_obj_name IN VARCHAR2, p_inputs VARCHAR2) RETURN NUMBER
IS
   return_val NUMBER := 0;
BEGIN
    FOR x IN (SELECT text valtext FROM user_views WHERE view_name =p_obj_name)
    LOOP
        IF ( x.valtext LIKE p_inputs ) THEN
           return_val :=1;
        END IF;
    END LOOP;
   RETURN return_val;
EXCEPTION
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
