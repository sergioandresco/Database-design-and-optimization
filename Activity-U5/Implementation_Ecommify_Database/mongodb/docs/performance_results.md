# Ecommify MongoDB Performance Results

| query                         | version             |   executionTimeMillis |   totalDocsExamined |   totalKeysExamined |   nReturned |   efficiency_ratio |
|:------------------------------|:--------------------|----------------------:|--------------------:|--------------------:|------------:|-------------------:|
| products_category_score_sales | before_natural_scan |                    24 |               32951 |                   0 |          50 |             659.02 |
| products_category_score_sales | after_indexes       |                     1 |                  50 |                  50 |          50 |               1    |
| reviews_negative_with_comment | before_natural_scan |                    98 |               98410 |                   0 |          50 |            1968.2  |
| reviews_negative_with_comment | after_indexes       |                    57 |                  50 |               10758 |          50 |               1    |
| catalog_top_sales_by_category | before_natural_scan |                    26 |               32951 |                   0 |          50 |             659.02 |
| catalog_top_sales_by_category | after_indexes       |                     0 |                  50 |                  50 |          50 |               1    |