WITH CTE_AGG_RANK_AND_SUM AS (
    SELECT 
         dm.title                                            AS MOVIE 
    ,    AVG(DATEDIFF(DAY, dm.release_date, fct.date))       AS AVG_DAYS_TO_SEE
    ,    LISTAGG(dg.genres, ';')                             AS ALL_GENRES 
    ,    COUNT(*)                                            AS COUNT_OF_DAYS_EXIBITION
    ,    SUM(fct.total)                                      AS TOTAL_AMNT 
    ,    SUM(fct.quantity)                                   AS SUM_OF_QUANTITY
    ,    TOTAL_AMNT * (1 + (1/COUNT_OF_DAYS_EXIBITION))      AS FACTOR_TOTAL
    ,    SUM_OF_QUANTITY * (1 + (1/COUNT_OF_DAYS_EXIBITION)) AS FACTOR_QTT
    FROM {{ ref('fact_sales') }} fct 
    INNER JOIN DIM_GENRES dg ON fct.genre_id = dg.genre_id
    INNER JOIN DIM_MOVIES dm ON fct.movie_id = dm.movie_id
    GROUP BY dm.title
)
SELECT 
     *
     EXCLUDE(FACTOR_TOTAL, FACTOR_QTT)
,    DENSE_RANK() OVER (ORDER BY FACTOR_TOTAL DESC) AS RANK_BY_TOTAL
,    DENSE_RANK() OVER (ORDER BY FACTOR_QTT DESC)   AS RANK_BY_QTT
FROM CTE_AGG_RANK_AND_SUM