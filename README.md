2010 US Census Shiny App
========================

| By      | Mikhail Y. Popov                                         |
| :---    | :---                                                     |
| email   | [mpopov@cmu.edu](mailto:mpopov@cmu.edu)|
| web     | [http://www.mpopov.com](http://www.mpopov.com)           |

Enables exploration of the 2010 US Census data from the [UScensus2010* package(s)][1] via a web interface created in R with Shiny.

The data on the counties, tracts, block groups, blocks, and CDPs totals  4.7 GB, which will take a while to download. When you've downloaded the packages, run:

```
install.packages(c("maptools","maps"));
install.packages(c(
"UScensus2010county_1.00.tar.gz",
"UScensus2010tract_1.00.tar.gz",
"UScensus2010blkgrp_1.00.tar.gz",
"UScensus2010cdp_1.00.tar.gz",
"UScensus2010blk_1.00.tar.gz",
"UScensus2010_0.11.zip"
), repos = NULL, type = "source")
```

Assuming you've installed the [shiny package][2] and that **shinyapp** is a folder in your working directory, run:

```
shiny::runApp("shinyapp")
```

Still need to add the remaining census variables because Total Population and Population Density are not the most exciting to study. ***I'll be adding features over time.*** For example, I'm considering incorporating the Public Use Microdata Sample files from the American Community Survey (PUMS ACS)...eventually.

Cheers!

[1]: http://lakshmi.calit2.uci.edu/census2000/
[2]: https://github.com/rstudio/shiny