SELECT 
     f.value['_id']::INT                                       AS ID
,    f.value['title']::VARCHAR(100)                            AS TITLE
,    f.value['overview']::TEXT                                 AS OVERVIEW
,    DATE(f.value['release_date']::VARCHAR(10), 'yyyy-mm-dd')  AS RELEASE_DATE
,    f2.value::VARCHAR(20)                                     AS GENRES
,    f.value['backdrop_path']::VARCHAR(100)                    AS BACKDROP_PATH
,    f.value['poster_path']::VARCHAR(100)                      AS POSTER_PATH
FROM {{ source('first_snow', 'raw_movies_content') }} rc
, LATERAL
    FLATTEN(input => rc.$1) f
, LATERAL
    FLATTEN(input => f.value['genres']) f2