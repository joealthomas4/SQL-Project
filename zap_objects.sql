CREATE OR REPLACE PROCEDURE Zap_objects(
    object_type_in IN VARCHAR2)
AS
TYPE t_tab
IS
  TABLE OF user_tables%ROWTYPE;
  objects_tab t_tab := t_tab();
TYPE seq_tab
IS
  TABLE OF user_sequences%ROWTYPE;
  objects_seq seq_tab := seq_tab();
  
TYPE trg_tab IS   TABLE OF user_triggers%ROWTYPE;
  objects_trg trg_tab := trg_tab();

TYPE view_tab IS  TABLE OF user_views%ROWTYPE;
  objects_view view_tab := view_tab();
TYPE object_tab IS TABLE OF all_objects%ROWTYPE;
  objects_obj object_tab := object_tab();
  v_sql VARCHAR2(2000);
  v_cnt NUMBER(9);
  

TYPE mview_logs IS   TABLE OF user_mview_logs%ROWTYPE;
  objects_mview_log mview_logs := mview_logs();

TYPE mview_TAB IS   TABLE OF USER_mviews%ROWTYPE;
  objects_MVIEWS mview_TAB := mview_TAB();  
  
BEGIN
  IF object_type_in = 'TABLE' THEN
    SELECT COUNT(*) INTO v_cnt FROM user_tables;
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_tab FROM user_tables;
      FOR i IN objects_tab.first .. objects_tab.last
      LOOP
        v_sql := 'Drop table ' || objects_tab(i).table_name || ' cascade constraints';
        EXECUTE immediate v_sql;
      END LOOP;
    END IF;
    RETURN;
  END IF;
  IF object_type_in = 'TRIGGER' THEN
    SELECT COUNT(*) INTO v_cnt FROM user_triggers;
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_trg FROM user_triggers;
      FOR i IN objects_trg.first .. objects_trg.last
      LOOP
        v_sql := 'Drop trigger ' || objects_trg(i).trigger_name ;
        EXECUTE immediate v_sql;
      END LOOP;
    END IF;
    RETURN;
  END IF;
  IF object_type_in = 'SEQUENCE' THEN
    SELECT COUNT(*) INTO v_cnt FROM user_sequences;
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_seq FROM user_sequences;
      FOR i IN objects_seq.first .. objects_seq.last
      LOOP
        v_sql := 'Drop sequence ' || objects_seq(i).sequence_name ;
        EXECUTE immediate v_sql;
      END LOOP;
    END IF;
    RETURN;
  END IF;
  IF object_type_in = 'VIEW' THEN
    SELECT COUNT(*) INTO v_cnt FROM user_views;
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_view FROM user_views;
      FOR i IN objects_view.first .. objects_view.last
      LOOP
        v_sql := 'Drop view ' || objects_view(i).view_name ;
        EXECUTE immediate v_sql;
      END LOOP;
    END IF;
    RETURN;
  END IF;
  
  IF object_type_in = 'MV_LOG' THEN
    SELECT COUNT(*) INTO v_cnt FROM user_mview_logs;    
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_mview_log FROM user_mview_logs;
      FOR i IN objects_mview_log.first .. objects_mview_log.last
      LOOP
        v_sql := 'drop materialized view log on ' || objects_mview_log(i).MASTER ;
        EXECUTE immediate v_sql;
      END LOOP;
    END IF;    
    RETURN;
  END IF;  
  
  IF object_type_in = 'MV' THEN
    SELECT COUNT(*) INTO v_cnt FROM USER_mviews;
    IF v_cnt > 0 THEN
      SELECT * BULK COLLECT INTO objects_MVIEWS FROM USER_mviews; 
      
      FOR i IN objects_MVIEWS.first .. objects_MVIEWS.last
      LOOP
        v_sql := 'drop materialized view ' || objects_MVIEWS(i).mview_name ;
        EXECUTE immediate v_sql;
      END LOOP;      
    END IF;
 
    RETURN;
  END IF; 
  
  --
  SELECT COUNT(*)
  INTO v_cnt
  FROM ALL_OBJECTS
  WHERE upper(OBJECT_TYPE) = upper(OBJECT_TYPE_IN)
  AND owner                = USER;
  IF v_cnt > 0 THEN
    SELECT * BULK COLLECT
    INTO objects_obj
    FROM ALL_OBJECTS
    WHERE upper(OBJECT_TYPE) = upper(OBJECT_TYPE_IN)
    AND owner                = USER;
    FOR i IN objects_obj.first .. objects_obj.last
    LOOP
      IF objects_obj(i).object_name != 'ZAP_OBJECTS' THEN
        v_sql                       := 'Drop ' || OBJECT_TYPE_IN || ' ' || objects_obj(i).object_name ;
        EXECUTE immediate v_sql;
      END IF;
    END LOOP;
  END IF;
END;
/
BEGIN
  Zap_objects('VIEW');
  Zap_objects('MV_LOG');
  Zap_objects('MV');
  Zap_objects('TRIGGER');
  Zap_objects('TABLE');
  Zap_objects('SEQUENCE');
  Zap_objects('PROCEDURE');
  Zap_objects('FUNCTION');
  Zap_objects('PACKAGE');
END;
/
DROP PROCEDURE Zap_objects;

PURGE RECYCLEBIN;
/