create or replace
PACKAGE BODY ap_users_ta AS
  -- apiver - revision
  apiver CONSTANT VARCHAR2(100) := '$Revision: 1 $';
  -- apiaut - author
  apiaut CONSTANT VARCHAR2(100) := '$Author: Author $';
  -- Fill ROWID
  PROCEDURE fill_rowid( p_rec IN OUT NOCOPY user_rec ) IS
  BEGIN
    IF p_rec.the_rowid IS NULL THEN
      SELECT ROWID INTO p_rec.the_rowid
        FROM apusers
        WHERE 
            id           = p_rec.id          ;        
    END IF;
  END fill_rowid;
  --
  PROCEDURE ins( p_tab IN OUT NOCOPY user_tab ) AS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      INSERT INTO apusers (
          id          
        , firstname   
        , lastname    
        , country     
        , create_date 
      ) VALUES (
          p_tab(v_ct). id          
        , p_tab(v_ct). firstname   
        , p_tab(v_ct). lastname    
        , p_tab(v_ct). country     
        , p_tab(v_ct). create_date 
      );               
    END LOOP;
  END ins;
  --
  PROCEDURE upd( p_tab IN OUT NOCOPY user_tab ) IS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      fill_rowid(p_tab(v_ct));
      UPDATE apusers SET 
          id           = p_tab(v_ct).id          
        , firstname    = p_tab(v_ct).firstname   
        , lastname     = p_tab(v_ct).lastname    
        , country      = p_tab(v_ct).country     
        , create_date  = p_tab(v_ct).create_date 
      WHERE  ROWID = p_tab(v_ct).the_rowid ;
    END LOOP;
  END upd;
  --
  PROCEDURE del( p_tab IN OUT NOCOPY user_tab ) AS
  BEGIN
    FOR v_ct IN 1 .. p_tab.COUNT
    LOOP
      fill_rowid(p_tab(v_ct));
      DELETE apusers
      WHERE ROWID = p_tab(v_ct).the_rowid;
    END LOOP;
  END del;
  --
  PROCEDURE slct( p_rec IN OUT NOCOPY user_rec ) IS
  BEGIN
    fill_rowid(p_rec);
    SELECT 
          id          
        , firstname   
        , lastname    
        , country     
        , create_date 
    INTO 
          p_rec. id          
        , p_rec. firstname   
        , p_rec. lastname    
        , p_rec. country     
        , p_rec. create_date 
    FROM apusers
    WHERE ROWID = p_rec.the_rowid;
  END slct;
  --
  FUNCTION exist_rec( p_rec IN user_rec ) RETURN BOOLEAN IS
    v_ret PLS_INTEGER := 0;
  BEGIN
    SELECT count(1) INTO v_ret
    FROM apusers
    WHERE 
          id          LIKE NVL(p_rec.id, id);
    RETURN (v_ret > 0);
  END Exist_rec;
  --
  PROCEDURE qry( p_cur IN OUT user_cur, p_rec IN user_rec ) AS
  BEGIN
    OPEN p_cur FOR
    SELECT ROWID
        , id          
        , firstname   
        , lastname    
        , country     
        , create_date 
    FROM apusers
    WHERE 
            NVL( id                , 0             ) = NVL( p_rec.id, NVL(id, 0 ) )
        AND UPPER(NVL( firstname   ,'0'           )) LIKE UPPER(NVL( p_rec.firstname, NVL(firstname,'0' )) )
        AND UPPER(NVL( lastname    ,'0'           )) LIKE UPPER(NVL( p_rec.lastname, NVL(lastname,'0' )) )
        AND UPPER(NVL( country     ,'0'           )) LIKE UPPER(NVL( p_rec.country, NVL(country,'0' )) )
        AND TRUNC(NVL( create_date , vgc_null_date )) = NVL(TRUNC( p_rec.create_date ), TRUNC(NVL(create_date, vgc_null_date )))
    ORDER BY 
          id          
        , firstname   
        , lastname    
        , country     
        , create_date ;
  END qry;
  --
  PROCEDURE qry (
     p_cur IN OUT user_cur 
        , p_id          user_row.id          %TYPE DEFAULT NULL
        , p_firstname   user_row.firstname   %TYPE DEFAULT NULL
        , p_lastname    user_row.lastname    %TYPE DEFAULT NULL
        , p_country     user_row.country     %TYPE DEFAULT NULL
        , p_create_date user_row.create_date %TYPE DEFAULT NULL
  ) IS
  BEGIN
    OPEN p_cur FOR
    SELECT ROWID
        , id          
        , firstname   
        , lastname    
        , country     
        , create_date 
    FROM apusers
    WHERE
            NVL( id                , 0             ) = NVL( p_id, NVL(id, 0 ) )
        AND UPPER(NVL( firstname   ,'0'           )) LIKE UPPER(NVL( p_firstname, NVL(firstname,'0' )) )
        AND UPPER(NVL( lastname    ,'0'           )) LIKE UPPER(NVL( p_lastname, NVL(lastname,'0' )) )
        AND UPPER(NVL( country     ,'0'           )) LIKE UPPER(NVL( p_country, NVL(country,'0' )) )
        AND TRUNC(NVL( create_date , vgc_null_date )) = NVL(TRUNC( p_create_date ), TRUNC(NVL(create_date, vgc_null_date )))
    ORDER BY 
          id          
        , firstname   
        , lastname    
        , country     
        , create_date ;
  END qry;
  --
END ap_users_ta;