CREATE OR REPLACE PACKAGE BODY tapi AS
  --
  v_svn_info  VARCHAR2(1000) := '
  -- apiver - revision
  apiver CONSTANT VARCHAR2(100) := ''$Revision: 1 $'';
  -- apiaut - author
  apiaut CONSTANT VARCHAR2(100) := ''$Author: Author $'';';
  --
  FUNCTION get_tapi_spec(
      p_sp_name   VARCHAR2
    , p_var_name  VARCHAR2
    , p_owner     VARCHAR2
  ) RETURN CLOB AS
    v_sp      CLOB := 'CREATE OR REPLACE PACKAGE ' || p_sp_name || '_ta AS' || v_svn_info;
    v_row     VARCHAR2(50) := p_var_name || '_row';
    v_rec     VARCHAR2(50) := p_var_name || '_rec';
    v_cur     VARCHAR2(50) := p_var_name || '_cur';
    v_tab   VARCHAR2(50) := p_var_name || '_tab';
    v_pk_cols VARCHAR2(30000);
    v_cols    VARCHAR2(30000);
    v_docs    VARCHAR2(30000);
    v_table   VARCHAR2(50);
  BEGIN
    vg_table := UPPER(REPLACE(p_sp_name, '_'));
    vg_owner := UPPER(p_owner);
    v_table := LOWER(vg_table);
    --
    OPEN vg_length_cur;
    FETCH vg_length_cur INTO vg_length_rec;
    CLOSE vg_length_cur;
    --
    OPEN vg_pk_cur;
    LOOP
      FETCH vg_pk_cur INTO vg_pk_rec;
      EXIT WHEN vg_pk_cur%NOTFOUND;
      v_pk_cols := v_pk_cols || '
    '|| vc_pref || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || v_row || '.' || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || '%TYPE';
    END LOOP;
    CLOSE vg_pk_cur;
    --
    OPEN vg_cur;
    LOOP
      FETCH vg_cur INTO vg_rec;
      EXIT WHEN vg_cur%NOTFOUND;
      v_cols := v_cols || '
    '|| vc_pref || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || v_row || '.' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || '%TYPE DEFAULT NULL';
      v_docs := v_docs || '
   * @param p_' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || '- ' || vg_rec.comments;
    END LOOP;
    CLOSE vg_cur;
    --
    v_sp := v_sp || '
  --
  vgc_null_date CONSTANT DATE := TO_DATE(''01.01.1970'',''DD.MM.YYYY'');
  /**
   * ROW type of the table ' || vg_table || '
   */
  ' || v_row || ' ' || v_table || ' %ROWTYPE;
  /**
   * Record type of the table ' || vg_table || '
   */
  TYPE ' || v_rec || ' IS RECORD (
      the_rowid ROWID' || REPLACE(REPLACE(v_cols, 'DEFAULT NULL'), vc_pref, ', ') || '
  );
  /**
   * Cursor
   */
  TYPE ' || v_cur || ' IS REF CURSOR RETURN ' || v_rec || ';
  /**
   * PL/SQL table
   */
  TYPE ' || v_tab || ' IS TABLE OF ' || v_rec || ' INDEX BY BINARY_INTEGER;
  /**
   * Insert rows
   * @param p_tab - PL/SQL table
   */ 
  PROCEDURE ins(p_tab IN OUT NOCOPY ' || v_tab || ');
  /**
   * Update rows
   * @param p_tab - PL/SQL table
   */
  PROCEDURE upd(p_tab IN OUT NOCOPY ' || v_tab || ');
  /**
   * Delete rows
   * @param p_tab - PL/SQL table
   */
  PROCEDURE del(p_tab IN OUT NOCOPY ' || v_tab || ');
  /**
   * Returns row based on ROWID
   * @param p_rec - definition record
   */
  PROCEDURE slct(p_rec IN OUT NOCOPY ' || v_rec || ');
  /**
   * Checks if the row exists based on primary key
   * @param p_rec - record with defined fields
   */
  FUNCTION exist_rec(p_rec IN ' || v_rec || ') RETURN BOOLEAN;
  /**
   * Returns REF CURSOR based on defined fields in the input record
   * @param p_cur - ref cursor
   * @param p_rec - record with defined fields
   */
  PROCEDURE qry(p_cur IN OUT ' || v_cur ||', p_rec IN ' || v_rec || ');
  /**
   * Returns REF CURSOR based on input parameters
   * @param p_cur - ref cursor' || v_docs || '
   */
  PROCEDURE qry (
      p_cur IN OUT ' || v_cur || v_cols || '
  );
  --
END ' || p_sp_name || '_ta;';
    RETURN v_sp;
  END get_tapi_spec;

  FUNCTION get_tapi_body(
      p_sp_name   VARCHAR2
    , p_var_name  VARCHAR2
    , p_owner     VARCHAR2
  ) RETURN CLOB AS
    v_sp          CLOB := 'CREATE OR REPLACE PACKAGE BODY ' || p_sp_name || '_ta AS' || v_svn_info;
    v_table       VARCHAR2(50);
    v_row       VARCHAR2(50) := p_var_name || '_row';
    v_pk_cols     VARCHAR2(30000);
    v_pk_cols_tab VARCHAR2(30000);
    v_cols        VARCHAR2(30000);
    v_cols_tab    VARCHAR2(30000);
    v_tab         VARCHAR2(30000);
    v_qry_where   VARCHAR2(30000);
    v_qry_where_pk  VARCHAR2(30000);
  BEGIN
    vg_table  := UPPER(REPLACE(p_sp_name, '_'));
    v_table   := LOWER(vg_table);
    vg_owner  := UPPER(p_owner);
    --
    OPEN  vg_length_cur;
    FETCH vg_length_cur INTO vg_length_rec;
    CLOSE vg_length_cur;
    --
    OPEN vg_pk_cur;
    LOOP
      FETCH vg_pk_cur INTO vg_pk_rec;
      EXIT WHEN vg_pk_cur%NOTFOUND;
      v_pk_cols := v_pk_cols || '
    '|| vc_pref || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || v_row || '.' || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || '%TYPE';
      v_pk_cols_tab := v_pk_cols_tab || '
        AND ' || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || '@TAB@' ||  RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || '%TYPE DEFAULT NULL';
      v_qry_where_pk := v_qry_where_pk || '
        AND ' || RPAD(vg_pk_rec.column_name, vg_length_rec.name_length + 1, ' ') || 'LIKE NVL(p_rec.' || vg_pk_rec.column_name || ', '|| vg_pk_rec.column_name ||')';
    END LOOP;
    CLOSE vg_pk_cur;
    --
    OPEN vg_cur;
    LOOP
      FETCH vg_cur INTO vg_rec;
      EXIT WHEN vg_cur%NOTFOUND;
      v_cols := v_cols || '
        , ' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ');
      v_cols_tab := v_cols_tab || '
        '|| vc_pref || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || '@TAB@' ||  RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || '%TYPE DEFAULT NULL';
      IF ( vg_rec.data_type = 'NUMBER') THEN
        v_qry_where := v_qry_where || '
        AND NVL( ' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1 + 6, ' ') || ', 0             ) = NVL( p_' || vg_rec.column_name || ', NVL('|| vg_rec.column_name ||', 0 ) )';
      ELSIF ( vg_rec.data_type = 'DATE') THEN
        v_qry_where := v_qry_where || '
        AND TRUNC(NVL( ' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || ', vgc_null_date )) = NVL(TRUNC( p_' || vg_rec.column_name || ' ), TRUNC(NVL('|| vg_rec.column_name ||', vgc_null_date )))';
      ELSE
        v_qry_where := v_qry_where || '
        AND UPPER(NVL( ' || RPAD(vg_rec.column_name, vg_length_rec.name_length + 1, ' ') || ',''0''           )) LIKE UPPER(NVL( p_' || vg_rec.column_name || ', NVL('|| vg_rec.column_name ||',''0'' )) )';
      END IF;
    END LOOP;
    CLOSE vg_cur;
    --
    v_sp := v_sp || '
  -- Fill ROWID
  PROCEDURE fill_rowid( p_rec IN OUT NOCOPY ' || p_var_name || '_rec ) IS
  BEGIN
    IF p_rec.the_rowid IS NULL THEN
      SELECT ROWID INTO p_rec.the_rowid
        FROM ' || v_table || '
        WHERE '|| REGEXP_REPLACE(REPLACE(REPLACE(v_pk_cols_tab, '@TAB@', ' = p_rec.'),'%TYPE DEFAULT NULL'), 'AND', '   ', 1, 1) ||';        
    END IF;
  END fill_rowid;
  --
  PROCEDURE ins( p_tab IN OUT NOCOPY ' || p_var_name || '_tab ) AS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      INSERT INTO ' || v_table || ' (' ||  REGEXP_REPLACE(v_cols, ',', ' ', 1, 1) || '
      ) VALUES (' || REGEXP_REPLACE(REPLACE(v_cols, ',', ', p_tab(v_ct).'), ',', ' ', 1, 1) || '
      );               
    END LOOP;
  END ins;
  --
  PROCEDURE upd( p_tab IN OUT NOCOPY ' || p_var_name || '_tab ) IS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      fill_rowid(p_tab(v_ct));
      UPDATE ' || v_table || ' SET ' 
      || REGEXP_REPLACE(
          REGEXP_REPLACE(
            REPLACE(
              REPLACE( v_cols_tab, '@TAB@', ' = p_tab(v_ct).' )
              ,'%TYPE DEFAULT NULL' )
            , vc_pref, ', ' )
          , ',', ' ', 1, 1 ) || '
      WHERE  ROWID = p_tab(v_ct).the_rowid ;
    END LOOP;
  END upd;
  --
  PROCEDURE del( p_tab IN OUT NOCOPY ' || p_var_name || '_tab ) AS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      fill_rowid(p_tab(v_ct));
      DELETE ' || v_table || '
      WHERE ROWID = p_tab(v_ct).the_rowid;
    END LOOP;
  END del;
  --
  PROCEDURE slct( p_rec IN OUT NOCOPY ' || p_var_name || '_rec ) IS
  BEGIN
    fill_rowid(p_rec);
    SELECT ' ||  REGEXP_REPLACE(v_cols, ',', ' ', 1, 1) || '
    INTO ' || REGEXP_REPLACE(REPLACE(v_cols, ',', ', p_rec.'), ',', ' ', 1, 1) || '
    FROM ' || v_table || '
    WHERE ROWID = p_rec.the_rowid;
  END slct;
  --
  FUNCTION exist_rec( p_rec IN ' || p_var_name || '_rec ) RETURN BOOLEAN IS
    v_ret PLS_INTEGER := 0;
  BEGIN
    SELECT count(1) INTO v_ret
    FROM ' || v_table || '
    WHERE ' ||  REGEXP_REPLACE(v_qry_where_pk, 'AND', ' ', 1, 1) || ';
    RETURN (v_ret > 0);
  END Exist_rec;
  --
  PROCEDURE qry( p_cur IN OUT ' || p_var_name || '_cur, p_rec IN ' || p_var_name || '_rec ) AS
  BEGIN
    OPEN p_cur FOR
    SELECT ROWID' || v_cols || '
    FROM ' || v_table || '
    WHERE ' || REGEXP_REPLACE(REPLACE(v_qry_where, '( p_', '( p_rec.'), 'AND', '   ', 1, 1) || '
    ORDER BY ' || REGEXP_REPLACE(v_cols, ',', ' ', 1, 1) || ';
  END qry;
  --
  PROCEDURE qry (
     p_cur IN OUT ' || p_var_name || '_cur ' || REPLACE(v_cols_tab, '@TAB@', p_var_name || '_row.') || '
  ) IS
  BEGIN
    OPEN p_cur FOR
    SELECT ROWID' || v_cols || '
    FROM ' || v_table || '
    WHERE' || REGEXP_REPLACE(v_qry_where, 'AND', '   ', 1, 1) || '
    ORDER BY ' || REGEXP_REPLACE(v_cols, ',', ' ', 1, 1) || ';
  END qry;
  --
END ' || p_sp_name || '_ta;';
    RETURN v_sp;
  END get_tapi_body;
  --
END tapi;
/
show errors

