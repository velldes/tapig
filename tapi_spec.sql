CREATE OR REPLACE PACKAGE tapi AS
  --
  vc_pref    CONSTANT VARCHAR2(50) := ', p_';
  vg_table  VARCHAR2(50);
  vg_owner  VARCHAR2(50);
  /**
  * Cursor is for table columns in primary key
  */
  CURSOR vg_pk_cur IS
    SELECT LOWER(cols.column_name) column_name
      , cols.position
    FROM all_constraints cons, all_cons_columns cols
    WHERE cols.table_name = vg_table
      AND cons.constraint_type = 'P'
      AND cons.constraint_name = cols.constraint_name
      AND cons.owner = cols.owner
    ORDER BY cols.table_name, cols.position;
  vg_pk_rec vg_pk_cur%ROWTYPE;
  /**
  * Cursor is for longest table column name
  */
  CURSOR vg_length_cur IS
    SELECT MAX(LENGTH(column_name)) name_length 
    FROM all_tab_columns 
    WHERE table_name = vg_table;
  vg_length_rec vg_length_cur%ROWTYPE;
  /**
  * Cursor is for table columns comments
  */
  CURSOR vg_cur IS
    SELECT tc.column_id
      , LOWER(tc.column_name) column_name
      , tc.data_type, cc.comments  
    FROM all_tab_columns tc, all_col_comments cc
    WHERE ( tc.table_name = cc.table_name 
        AND tc.column_name = cc.column_name  
        AND tc.owner = cc.owner
      )
      AND tc.owner = vg_owner
      AND tc.table_name = vg_table
    ORDER BY column_id;
  vg_rec vg_cur%ROWTYPE;
  --
  FUNCTION get_tapi_spec(
      p_sp_name   VARCHAR2
    , p_var_name  VARCHAR2
    , p_owner     VARCHAR2
  ) RETURN CLOB;
  --
  FUNCTION get_tapi_body(
      p_sp_name   VARCHAR2
    , p_var_name  VARCHAR2
    , p_owner     VARCHAR2
  ) RETURN CLOB;
  --
END tapi;
/
show errors
