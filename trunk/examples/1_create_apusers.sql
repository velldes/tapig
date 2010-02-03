/*
DROP TABLE apusers;
DROP PACKAGE ap_users_ta;
*/

CREATE TABLE apusers (
    id          NUMBER NOT NULL PRIMARY KEY
  , firstname   VARCHAR2(50)
  , lastname    VARCHAR2(50)
  , country     VARCHAR2(50)
  , create_date DATE
)
/

COMMENT ON TABLE apusers IS 'Information about users'
/

COMMENT ON COLUMN apusers.id IS 'User ID'
/

COMMENT ON COLUMN apusers.firstname IS 'User first name'
/

COMMENT ON COLUMN apusers.lastname IS 'User last name'
/

COMMENT ON COLUMN apusers.country IS 'User country'
/

COMMENT ON COLUMN apusers.create_date IS 'User creation date'
/

DECLARE
  v_sp      VARCHAR2(32767);
  v_sp_name VARCHAR2(50) := 'ap_users';
  v_var_name     VARCHAR2(50) := 'user';
  v_owner   VARCHAR2(50) := 'user';
BEGIN
    v_sp  := tapi.get_tapi_spec( v_sp_name, v_var_name, v_owner );
    EXECUTE IMMEDIATE v_sp; 
    v_sp  := tapi.get_tapi_body( v_sp_name, v_var_name, v_owner );
    EXECUTE IMMEDIATE v_sp; 
END;














