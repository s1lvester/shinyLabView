shinyLabView docs
================
Markus Bockhacker

(assorted write-along during programming)

What?
=====

This is a Shiny web app to visualize lab results from csv input data. This is a study-project from "Beuth University of Apllied Sciences (<https://www.beuth-hochschule.de>)

Students: \* Semra Kocack \* Christopher Secker \* Markus Bockhacker

Currently this project has no licence - this will change in the future.

CAVE / BEWARE:
--------------

this projects uses lab parameters that are familiar to german physicians in clinical practice and therefore are not always proper si-units!

#### Lab Data (input)

comma-separated-values (csv) are read from a file.

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

#### Lookup table for patient-data

comma-separated-values (csv) are read from a file.

| Parameter | Data.Type       |
|:----------|:----------------|
| patientId | Integer         |
| sex       | Boolean \[m/f\] |
| age       | Integer         |
| name      | String          |
| firstName | String          |

#### Normal values

comma-separated-values (csv) are read from a file. Source: <http://www.laborlexikon.de/Referenzen.htm>

| Parameter |  female.min|  female.max|  male.min|  male.max|
|:----------|-----------:|-----------:|---------:|---------:|
| na        |    1.35e+02|    1.45e+02|  1.35e+02|  1.45e+02|
| k         |    3.80e+00|    5.20e+00|  3.80e+00|  5.20e+00|
| krea      |    6.60e-01|    1.09e+00|  8.10e-01|  1.44e+00|
| hst       |    2.10e+01|    4.30e+01|  1.80e+01|  5.50e+01|
| gfr       |    0.00e+00|    9.99e+02|  0.00e+00|  9.99e+02|
| hgb       |    1.20e+01|    1.60e+01|  1.40e+01|  1.80e+01|
| rbc       |    4.30e+00|    5.20e+00|  4.80e+00|  5.90e+00|
| plt       |    1.50e+05|    4.00e+05|  1.50e+05|  4.00e+05|
| wbc       |    4.00e+03|    1.00e+04|  4.00e+03|  1.00e+04|
| inr       |    8.50e-01|    1.27e+00|  8.50e-01|  1.27e+00|
| ptt       |    2.00e+01|    3.80e+01|  2.00e+01|  3.80e+01|

### Random Datasets

``` r
library(lubridate)
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

``` r
normvalues <- read.csv2("./input_data_structures/norm-Lab results input data structure.csv")

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
    v[11] <- runif(1, 4000, 2*10^6) # plt
    v[12] <- runif(1, 100, 40000) # wbc
    v[13] <- runif(1, 0.1, 5.0) # inr
    v[14] <- runif(1, 15, 80) # ptt
    
    store[[k]] <- v
  }
}

store <- as.data.frame(do.call("rbind", store))
colnames(store) <- c("resultId", "patientId", "date", "na", "k", "krea", "hst", "gfr", "hgb", "rbc", "plt", "wbc", "inr", "ptt") 

write.csv2(store, "../shinyLabView/dummyValues.csv")
```

"internal API"
--------------

In order to build a modular program there's need for an internal api or convention on how to call testcases. Testcases can either reverence the whole dataset or a subset by patientId and/or date.

Pseudocode:

    function testCase1 (dataSet, patientId, timeStampFrom, timeStampTo) {
      ...
      return MessageString "result"
    }
