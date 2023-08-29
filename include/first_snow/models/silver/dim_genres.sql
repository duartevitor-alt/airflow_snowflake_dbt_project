SELECT
    DISTINCT 
    {{ dbt_utils.generate_surrogate_key(['GENRES']) }} AS GENRE_ID
,   GENRES
FROM {{ ref('raw_int_normalized') }}