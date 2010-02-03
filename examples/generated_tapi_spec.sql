create or replace
PACKAGE ap_users_ta AS
  -- apiver - revision
  apiver CONSTANT VARCHAR2(100) := '$Revision: 1 $';
  -- apiaut - author
  apiaut CONSTANT VARCHAR2(100) := '$Author: Author $';
  --
  vgc_null_date CONSTANT DATE := TO_DATE('01.01.1970','DD.MM.YYYY');
  /**
   * ROW type of the table APUSERS
   */
  user_row apusers %ROWTYPE;
  /**
   * Record type of the table APUSERS
   */
  TYPE user_rec IS RECORD (
      the_rowid ROWID
    , id          user_row.id          %TYPE 
    , firstname   user_row.firstname   %TYPE 
    , lastname    user_row.lastname    %TYPE 
    , country     user_row.country     %TYPE 
    , create_date user_row.create_date %TYPE 
  );
  /**
   * Cursor
   */
  TYPE user_cur IS REF CURSOR RETURN user_rec;
  /**
   * PL/SQL table
   */
  TYPE user_tab IS TABLE OF user_rec INDEX BY BINARY_INTEGER;
  /**
   * Insert rows
   * @param p_tab - PL/SQL table
   */ 
  PROCEDURE ins(p_tab IN OUT NOCOPY user_tab);
  /**
   * Update rows
   * @param p_tab - PL/SQL table
   */
  PROCEDURE upd(p_tab IN OUT NOCOPY user_tab);
  /**
   * Delete rows
   * @param p_tab - PL/SQL table
   */
  PROCEDURE del(p_tab IN OUT NOCOPY user_tab);
  /**
   * Returns row based on ROWID
   * @param p_rec - definition record
   */
  PROCEDURE slct(p_rec IN OUT NOCOPY user_rec);
  /**
   * Checks if the row exists based on primary key
   * @param p_rec - record with defined fields
   */
  FUNCTION exist_rec(p_rec IN user_rec) RETURN BOOLEAN;
  /**
   * Returns REF CURSOR based on defined fields in the input record
   * @param p_cur - ref cursor
   * @param p_rec - record with defined fields
   */
  PROCEDURE qry(p_cur IN OUT user_cur, p_rec IN user_rec);
  /**
   * Returns REF CURSOR based on input parameters
   * @param p_cur - ref cursor
   * @param p_id          - User ID
   * @param p_firstname   - User first name
   * @param p_lastname    - User last name
   * @param p_country     - User country
   * @param p_create_date - User creation date
   */
  PROCEDURE qry (
      p_cur IN OUT user_cur
    , p_id          user_row.id          %TYPE DEFAULT NULL
    , p_firstname   user_row.firstname   %TYPE DEFAULT NULL
    , p_lastname    user_row.lastname    %TYPE DEFAULT NULL
    , p_country     user_row.country     %TYPE DEFAULT NULL
    , p_create_date user_row.create_date %TYPE DEFAULT NULL
  );
  --
END ap_users_ta;