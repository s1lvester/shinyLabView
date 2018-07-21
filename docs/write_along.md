shinyLabView docs
================
Markus Bockhacker

-   [What?](#what)
-   [CAVE / BEWARE](#cave-beware)
-   [Input Data](#input-data)
    -   [Lab data](#lab-data)
        -   [Lookup table for patient-data](#lookup-table-for-patient-data)
        -   [Normal values](#normal-values)
        -   [Random Datasets to create lab data](#random-datasets-to-create-lab-data)
-   ["internal API"](#internal-api)
-   [UI & Visualisation](#ui-visualisation)
    -   [datatables.net and DT](#datatables.net-and-dt)
        -   [Selection and FixedColumns](#selection-and-fixedcolumns)
        -   [normValues](#normvalues)
    -   [Line graph (ggplot2 & plot.ly)](#line-graph-ggplot2-plot.ly)
        -   [Reversing Time](#reversing-time)
        -   [De-factorisation](#de-factorisation)

What?
=====

-   This is a Shiny web app to visualize lab results from csv input data.
-   This is a study-project from "Beuth University of Apllied Sciences (<https://www.beuth-hochschule.de>)
-   This file is an assorted write-along during programming.

Students involved in the project:

-   Semra Kocack
-   Christopher Secker
-   Markus Bockhacker

Currently this project has no licence - this will change in the future.

CAVE / BEWARE
=============

this projects uses lab parameters that are familiar to german physicians in clinical practice and therefore are not always proper si-units!

Input Data
==========

comma-separated-values (csv) are read from a file.

Lab data
--------

| Parameter | Data.Type      | Unit               |
|:----------|:---------------|:-------------------|
| resultId  | Integer        | no dimension       |
| patientId | Integer        | no dimension       |
| date      | Timestamp      | (YYYY-MM-DD-HH-MM) |
| na        | Floating point | \[mmol/l\]         |
| k         | Floating point | \[mmol/l\]         |
| krea      | Floating point | \[mg/dl\]          |
| hst       | Floating point | \[mg/dl\]          |
| gfr       | Integer        | \[ml/min\]         |
| hgb       | Floating point | \[g/dl\]           |
| rbc       | Integer        | \[10^6/µl\]        |
| plt       | Integer        | \[/µl\]            |
| wbc       | Floating point | \[/µl\]            |
| inr       | Floating point | no dimension       |
| ptt       | Floating point | \[sec\]            |

### Lookup table for patient-data

comma-separated-values (csv) are read from a file.

| Parameter | Data.Type       |
|:----------|:----------------|
| patientId | Integer         |
| sex       | Boolean \[m/f\] |
| age       | Integer         |
| name      | String          |
| firstName | String          |

### Normal values

comma-separated-values (csv) are read from a file. Source: <http://www.laborlexikon.de/Referenzen.htm>

| parameter | unit   |  female.min|  female.max|  male.min|  male.max|
|:----------|:-------|-----------:|-----------:|---------:|---------:|
| na        | mmol/l |      135.00|      145.00|    135.00|    145.00|
| k         | mmol/l |        3.80|        5.20|      3.80|      5.20|
| krea      | mg/dl  |        0.66|        1.09|      0.81|      1.44|
| hst       | mg/dl  |       21.00|       43.00|     18.00|     55.00|
| gfr       | ml/min |       90.00|      999.00|     90.00|    999.00|
| hgb       | g/dl   |       12.00|       16.00|     14.00|     18.00|
| rbc       | mio/ul |        4.30|        5.20|      4.80|      5.90|
| plt       | tsd/ul |      150.00|      400.00|    150.00|    400.00|
| wbc       | tsd/ul |        4.00|       10.00|      4.00|     10.00|
| inr       |        |        0.85|        1.27|      0.85|      1.27|
| ptt       | sec    |       20.00|       38.00|     20.00|     38.00|

### Random Datasets to create lab data

``` r
library(lubridate)

store <- list()
v <- numeric(14)
k <- 0

for (i in 1:40) {
  for (j in 1:20) {
    k <- k+1
    v[1] <- k # resultId
    v[2] <- j # patientId
    v[3] <- as_datetime(now() - runif(1, 0, 10^7)) # Unix Timestamp magic
    v[4] <- runif(1, 120.0, 155.0) # na
    v[5] <- runif(1, 2.0, 10.5) # k
    v[6] <- runif(1, 0.2, 10.0) # krea
    v[7] <- runif(1, 10.0, 80.0) # hst
    v[8] <- runif(1, 0, 250) # gfr
    v[9] <- runif(1, 2.0, 18.0) # hgb
    v[10] <- runif(1, 2.0, 6.0) # rbc
    v[11] <- runif(1, 20, 1000) # plt
    v[12] <- runif(1, 0.1, 42) # wbc
    v[13] <- runif(1, 0.1, 5.0) # inr
    v[14] <- runif(1, 15, 80) # ptt
    
    store[[k]] <- v
  }
}

store <- as.data.frame(do.call("rbind", store))
colnames(store) <- c("resultId", "patientId", "date", "na", "k", "krea", "hst", "gfr", "hgb", "rbc", "plt", "wbc", "inr", "ptt") 

write.csv(store, "../shinyLabView/labData.csv")
```

"internal API"
==============

In order to build a modular program there's need for an internal api or convention on how to call testcases. Testcases can either reverence the whole dataset or a subset by patientId and/or date.

Pseudocode:

    function testCase1 (dataSet, patientId, timeStampFrom, timeStampTo) {
      ...
      return MessageString "result"
    }

UI & Visualisation
==================

datatables.net and DT
---------------------

DT is a R Interface to the jQuery Plug-in DataTables (<https://rstudio.github.io/DT>).

### Selection and FixedColumns

Selection of rows doesn't really work with FixedColumns (<https://github.com/rstudio/DT/issues/275#issuecomment-355610296>). Instead I disabled click-enents via css for fixed table-columns via `pointerEvents = "none"`.

aka: terrible hack. See also: <https://github.com/s1lvester/shinyLabView/issues/6>

### normValues

NormValues are gender-specific. I used two different variable (Vector "femaleNormValuesCol" and data.frome "femaleNormValues") to store character and numeric values. Characters are bound to the displayData as row number 1, numeric values are appended to the tail of the rowset and thus form the last two rows. Afterwards they can be seperately formated. Numeric values will be hidden after transposing the table (visible = FALSE in columnDefs option) and characters will be styled with CSS.

Since DT doesn't include any helper-functions to style individual cells in rows on conditions and since formatStyle(target = row) always styles the whole row (See: <https://rstudio.github.io/DT/010-style.html>), Instead I worte a "rowCallback" function, which is just jQuery style JS which executes as every row is rendered.

See: <https://datatables.net/reference/option/rowCallback> and <https://datatables.net/manual/data/>

Line graph (ggplot2 & plot.ly)
------------------------------

Line graph is designed using ggplot2 because it's much more flexible with ribbon plots and turned into a plot.ly graphig using ggplotly().

### Reversing Time

Unfortunately "scale\_x\_reverse()" doesn't work with "scale\_x\_datetime()" so it's neccessary to implement a helper-function to reverse the datetime x scale in the plot.

### De-factorisation

When reading files (and parsing them through reactive components in shiny) more often than not you'll recieve a Factor instead of a simple data-type like a Vector. In theory this factor also includes "historical" data on what led to this factors values - but in order to use them in a function that expects a list or vector we need to parse them two times.

    as.numeric(as.character(FACTOR))

According to the docs this is the most inefficient, but most readable way.
