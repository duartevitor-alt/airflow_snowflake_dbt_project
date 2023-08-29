WITH fct_invoices_cte AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY "DATE" DESC) AS REG_ID
    ,   DATE  
    ,   {{ dbt_utils.generate_surrogate_key(['GENRES']) }} AS GENRE_ID
    ,   {{ dbt_utils.generate_surrogate_key(['MOVIE']) }}  AS MOVIE_ID
    ,   QUANTTY          AS QUANTITY
    ,   PRICE            AS PRICE
    ,   QUANTTY * PRICE  AS TOTAL
    FROM {{ source('first_snow', 'raw_transactional_sales_movies_fill') }}
)
SELECT
     fi.REG_ID
,    fi.DATE
,    dm.MOVIE_ID
,    dg.GENRE_ID
,    fi.QUANTITY
,    fi.PRICE
,    fi.TOTAL
FROM fct_invoices_cte fi
INNER JOIN {{ ref('dim_genres') }} dg ON fi.GENRE_ID = dg.GENRE_ID
INNER JOIN {{ ref('dim_movies') }} dm ON fi.MOVIE_ID = dm.MOVIE_ID