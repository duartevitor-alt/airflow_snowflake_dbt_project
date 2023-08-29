SELECT
    DISTINCT 
    {{ dbt_utils.generate_surrogate_key(['TITLE']) }} AS MOVIE_ID
,   TITLE
,   RELEASE_DATE
FROM {{ ref('raw_int_normalized') }}