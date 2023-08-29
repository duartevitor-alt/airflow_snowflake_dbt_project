SELECT 
    *
FROM {{ ref('raw_stag_normalized') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY ID, GENRES ORDER BY ID) = 1