<!-- README.md is generated from README.Rmd. Please edit that file -->
ddpcr: Analysis and visualization of Digital Droplet PCR data in R and on the web
=================================================================================

[![Build Status](https://travis-ci.org/daattali/ddpcr.svg?branch=master)](https://travis-ci.org/daattali/ddpcr)

This package provides an interface to explore, analyze, and visualize droplet digital PCR (ddPCR) data in R. An interactive tool was also created and is available online to facilitate this analysis for anyone who is not comfortable with using R.

Background
==========

Droplet Digital PCR (ddPCR) is a technology provided by Bio-Rad for performing digital PCR. The basic workflow of ddPCR involves three main steps: partitioning sample DNA into 20,000 droplets, PCR amplifying the nucleic acid in each droplet, and finally passing the droplets through a reader that detects flurescent intensities in two different wavelengths corresponding to FAM and HEX dyes. As a result, the data obtained from a ddPCR experiment can be visualized as a 2D scatterplot (one dimension is FAM intensity and the other dimension is HEX intensity) with 20,000 points (each droplet represents a point).

ddPCR experiments can be defined as singleplex, duplex, or multiplex depending on the number of dyes used (one, two, and more than two, respectively). A duplex experiment typically uses one FAM dye and one HEX dye, and consequently the droplets will be grouped into one of four clusters: double-negative (not emitting fluorescence from either dye), HEX-positive, FAM-positive, or double-positive. When plotting the droplets, each quadrant of the plot corresponds to a cluster; for example, the droplets in the lower-left quadrant are the double-negative droplets.

After running a ddPCR experiment, a key step in the analysis is gating the droplets to determine how many droplets belong to each cluster. Bio-Rad provides an analysis software called QuantaSoft which can be used to perform gating. QuantaSoft can either do the gating automatically or allow the user to set the gates manually. Most ddPCR users currently gate their data manually because QuantaSoft's automatic gating often does a poor job and **there are no other tools available for gating ddPCR data**.

Overview
========

The `ddpcr` package allows you to upload ddPCR data, perform some basic analysis, explore characteristic of the data, and create customizable figures of the data.

Main features
-------------

The main features include:

-   **Identify failed wells** - determining which wells in the plate seemed to have failed the ddPCR experiment, and thus these wells will be excluded from all downstream analysis. No template control (NTC) will be deemed as failures by this tool.
-   **Identify outlier droplets** - sometimes a few droplets can have an extremely high fluorescent intensity value that is probably erroneous, perhaps as a result of an error with the fluorescent reader. These droplets are identified and removed from the downstream analysis.
-   **Identify empty droplets** - droplets with very low fluorescent emissions are considered empty and are removed from the downstream analysis. Removing these droplets is beneficial for two reasons: 1. the size of the data is greatly reduced, which means the computations will be faster on the remaining droplets, and 2. the real signal of interest is in the non-empty droplets, and empty droplets can be regarded as noise.
-   **Calculating template concentration** - after knowing how many empty droplets are in each well, the template concentration in each well can be calculated.
-   **Gating droplets** - if your experiment matches some criteria (more on that soon), then automatic gating can take place; otherwise, you can gate the data manually just like on QuantaSoft.
-   **Explore results** - the results from each well (\# of drops, \# of outliers, \# of empty drops, concentration) can be explored as a histogram or boxplot to see the distribution of all wells in the plate.
-   **Plot** - you can plot the data in the plate with many customizable features.

Supported experiment types
--------------------------

While this tool was originally developed to automatically gate data for a particular ddPCR assay (the paper for that experiment is in progress), any assay with similar characteristics can also use this tool to automatically gate the droplets. In order to benefit from the full automatic analysis, your ddPCR experiment needs to have these characteristics:

-   The experiment is a duplex ddPCR experiment
-   The majority of droplets are empty (double-negative)
-   The majority of non-empty droplets are double-positive
-   There can be a third cluster of either FAM+ or HEX+ droplets

In other words, the built-in automatic gating will work when there are three clusters of droplets: (1) double-negative, (2) double-positive, and (3) either FAM+ or HEX+. These types of experiments will be referred to as **(FAM+)/(FAM+HEX+)** or **(HEX+)/(FAM+HEX+)**. Both of these experiment types fall under the name of **PNPP experiments**; PNPP is short for PositiveNegative/PositivePositive, which is a reflection of the droplet clusters. Here is what a typical well from a PNPP experiment looks like:

[![Supported experiment types](vignettes/figures/supported-exp-types.png)](vignettes/figures/supported-exp-types.png)

If your experiment matches the criteria for a **PNPP** experiment (either a **(FAM+)/(FAM+HEX+)** or a **(HEX+)/(FAM+HEX+)** experiment), then after calculating empty droplets the program will analyze the rest of the droplets and assign each droplet one of the following three clustes: FAM+ (or HEX+), FAM+HEX+, or rain. Here is the result of analyzing a single well from a **(FAM+)/(FAM+HEX+)** experiment:

[![Analyze result](vignettes/figures/ppnp-simple-result.png)](vignettes/figures/ppnp-simple-result.png)

If your ddPCR experiment is not a **PNPPP** type, you can still use this tool for the rest of the analysis, exploration, and plotting, but it will not benefit from the automatic gating. However, `ddpcr` is built to be easily extensible, which means that you can add your own experiment "type". Custom experiment types need to define their own method for gating the droplets in a well, and then they can be used in the same way as the built-in experiment types.

Analysis using the interactive tool
===================================

If you're not comfortable using R and would like to use a visual tool that requires no programming, you can [use the tool online](TODO). If you do know how to run R, using the interactive tool (built with [shiny](http://shiny.rstudio.com/))

Analysis using R
================

Enough talking, time for action!

First, install `ddpcr`

    devtools::install_github("daattali/ddpcr")

Quick start
-----------

Here are two basic examples of how to use `ddpcr` to analyze and plot your ddPCR data. One example shows an analysis where the gating thresholds are manually set, and the other example uses the automated analysis. Note how `ddpcr` is designed to play nicely with the [magrittr pipe](https://github.com/smbache/magrittr) `%>%` for easier pipeline workflows. Explanation will follow, these are just here as a spoiler.

``` r
library(ddpcr)
dir <- system.file("sample_data", "small", package = "ddpcr")

# example 1: manually set thresholds
new_plate(dir, type = CROSSHAIR_THRESHOLDS) %>%
  subset("B01,B06") %>%
  set_thresholds(c(5000, 7500)) %>%
  analyze %>%
  plot(show_grid_labels = TRUE, title = "Ex 1 - manually set gating thresholds")

# example 2: automatic gating
new_plate(dir, type = FAM_POSITIVE_PPNP) %>%
  subset("B01:B06") %>%
  analyze %>%
  plot(show_mutant_freq = FALSE, show_grid_labels = TRUE, title = "Ex 2 - automatic gating")
```

<img src="vignettes/README-quickstart-1.png" title="" alt="" width="50%" /><img src="vignettes/README-quickstart-2.png" title="" alt="" width="50%" />

Running a full analysis - walkthrough
-------------------------------------

This section will go into details of how to use `ddpcr` to analyze ddPCR data.

### Loading ddPCR data

The first step is to get the ddPCR data into R. `ddpcr` uses the data files that are exported by QuantaSoft as its input. You need to have all the well files for the wells you want to analyze (one file per well), and you can optionally add the results file from QuantaSoft. If you loaded an experiment named *2015-05-20\_mouse* with 50 wells to QuantaSoft, then QuantaSoft will export the following files:

-   50 data files (well files): each well will have its own file with the name ending in \*\_Amplitude.csv". For example, the droplets in well A01 will be saved in *2015-05-20\_mouse\_A01\_Aamplitude.csv*
-   1 results file: a small file named *2015-05-20\_mouse.csv* will be generated with some information about the plate, including the name of the sample in each well (assuming you named the samples previously)

The well files are the only required input to `ddpcr`, and since ddPCR plates contain 96 wells, you can upload anywhere from 1 to 96 well files. The results file is not mandatory, but if you don't provide it then the wells will not have sample names attached to them.

`ddpcr` contains a sample dataset called *small* that has 5 wells. We use the `new_plate()` function to initialize a new ddPCR plate object. If given a directory, it will automatically find all the valid well files in the directory and attempt to find a matching results file.

``` r
library(ddpcr)
dir <- system.file("sample_data", "small", package = "ddpcr")
plate <- new_plate(dir)
#> Reading data files into plate... DONE (0 seconds)
#> Initializing plate of type `ddpcr_plate`... DONE (0 seconds)
```

You will see some messages appear - every time `ddpcr` runs an analysis step (initializing the plate is part of the analysis), it will output a message decribing what it's doing.

### Explore the data pre-analysis

We can explore the data we loaded even before doing any analysis

``` r
plate
#> ddpcr plate
#> -----------
#> Dataset name: small
#> Plate type: ddpcr_plate
#> Data summary: 5 wells; 76,143 drops
#> Completed analysis steps: INITIALIZE
#> Remaining analysis steps: REMOVE_FAILURES, REMOVE_OUTLIERS, REMOVE_EMPTY
```

Among other things, this tells us how many wells and total droplets we have in the data, and what steps of the analysis are remaining. All the information that gets shown when you print a ddpcr plate object is also available through other functions that are dedicated to show one piece of information. For example

``` r
plate %>% name  # equivalent to `name(plate)`
#> [1] "small"
plate %>% type  # equivalent to `type(plate)`
#> [1] "ddpcr_plate"
```

Since we didn't specify an experiment type, this plate object has the default type of `ddpcr_plate`.

We can see what wells are in our data with `wells_used()`

``` r
plate %>% wells_used
#> [1] "B01" "B06" "C01" "C06" "C09"
```

There are 5 wells because the sample data folder has 5 well files.

We can see all the droplets data with `plate_data()`

``` r
plate %>% plate_data
#> Source: local data frame [76,143 x 4]
#> 
#>    well  HEX  FAM cluster
#> 1   B01 1374 1013       1
#> 2   B01 1411 1018       1
#> 3   B01 1428 1024       1
#> 4   B01 1313 1026       1
#> 5   B01 1362 1027       1
#> 6   B01 1290 1028       1
#> 7   B01 1319 1030       1
#> 8   B01 1492 1032       1
#> 9   B01 1312 1036       1
#> 10  B01 1294 1037       1
#> ..  ...  ...  ...     ...
```

This shows us the fluorescent intensities of each droplet, along with the current cluster assignment of each droplet. Right now all droplets are assigned to cluster 1 which corresponds to *undefined* since no analysis has taken place yet. You can see all the clusters that a droplet can belong to with the `clusters()` function

``` r
plate %>% clusters
#> [1] "UNDEFINED" "FAILED"    "OUTLIER"   "EMPTY"
```

This tells us that any droplet in a `ddpcr_plate`-type experiment can be classified into those clusters.

We can see the results of the plate so far with `plate_meta()`

``` r
plate %>% plate_meta(only_used = TRUE)
#>   well sample row col used drops
#> 1  B01     #1   B   1 TRUE 17458
#> 2  B06     #9   B   6 TRUE 13655
#> 3  C01     #3   C   1 TRUE 15279
#> 4  C06    #12   C   6 TRUE 14513
#> 5  C09    #30   C   9 TRUE 15238
```

The `only_used` parameter is used so that we'll only get data about the 5 existing wells and ignore the other 91 unused wells on the plate. Notice that *meta* (short for *metadata*) is used instead of *results*. This is because the meta/results table contains information for each well such as its name, number of drops, number of empty drops, concentration, and many other calculated values.

### Subset the plate

If you aren't interested in all the wells, you can use the `subset()` function to retain only certain wells. Alternatively, you can use the `data_files` argument of the `new_plate()` function to only load certain well files instead of a full directory.
The `subset()` function can take accept either a list of sample names, a list of wells, or a special *range notation*. The range notation is a convenient way to select many wells: use a colon (`:`) to specify a range of wells and a comma (`,`) to add another well or range. A range of wells is defined as all wells in the rectangular area between the two endpoints. For example, `B05:C06` corresponds to the four wells `B05, B06, C05, C06`. The following diagram shows the result of subsetting with a range notation of `A01:H03, C05, E06, B07:C08` on a plate that initially contains all 96 wells.

[![Subset example](vignettes/figures/ex-subset.png)](vignettes/figures/ex-subset.png)

Back to our data: we have 5 wells, let's keep 4 of them

``` r
plate <- plate %>% subset("B01:C06")
# could have also used subset("B01, B06, C01, C06")
plate %>% wells_used
#> [1] "B01" "B06" "C01" "C06"
```

### Run analysis

An analysis of a ddPCR plate consists of running the plate through a sequence of steps. If you care to know, you can see what all the steps for a particular experiment are

``` r
plate %>% steps %>% names
#> [1] "INITIALIZE"      "REMOVE_FAILURES" "REMOVE_OUTLIERS" "REMOVE_EMPTY"
```

These steps are the default steps that any ddpcr plate will go through by default if no type is specified. At this point all we did was load the data, so the initialization step was done and there are 3 remaining steps. You can either run through the steps one by one using `next_steps()` or run all remaining steps with `analyze()`.

``` r
plate <- plate %>% analyze
#> Identifying failed wells... DONE (0 seconds)
#> Identifying outlier droplets... DONE (0 seconds)
#> Identifying empty droplets... DONE (1 seconds)
#> Analysis complete
# equivalent to `plate %>% next_step(3)`
# also equivalent to `plate %>% next_step %>% next_step %>% next_step`
```

As each step of the analysis is performed, a message describing the current step is printed to the screen. Since we only have 2 wells, it should be very fast, but when you have a full 96-well plate, the analysis could take several minutes. Sometimes it can be useful to run each step individually rather than all of them together if you want to inspect the data after each step.

### Explore the data post-analysis

We can explore the plate again, now that it has been analyzed.

``` r
plate
#> ddpcr plate
#> -----------
#> Dataset name: small
#> Plate type: ddpcr_plate
#> Data summary: 4 wells; 60,905 drops
#> Analysis completed
```

We now get a message that says the analysis is complete (earlier it said what steps are remaining). We can also look at the droplets data

``` r
plate %>% plate_data
#> Source: local data frame [60,905 x 4]
#> 
#>    well  HEX  FAM cluster
#> 1   B01 1374 1013       4
#> 2   B01 1411 1018       4
#> 3   B01 1428 1024       4
#> 4   B01 1313 1026       4
#> 5   B01 1362 1027       4
#> 6   B01 1290 1028       4
#> 7   B01 1319 1030       4
#> 8   B01 1492 1032       4
#> 9   B01 1312 1036       4
#> 10  B01 1294 1037       4
#> ..  ...  ...  ...     ...
```

This isn't very informative since it shows the cluster assignment for each droplet, which is not easy for a human to digest. Instead, this information can be visualized by plotting the plate (coming up). We can also look at the plate results

``` r
plate %>% plate_meta(only_used = TRUE)
#>   well sample row col used drops success
#> 1  B01     #1   B   1 TRUE 17458    TRUE
#> 2  B06     #9   B   6 TRUE 13655    TRUE
#> 3  C01     #3   C   1 TRUE 15279    TRUE
#> 4  C06    #12   C   6 TRUE 14513   FALSE
#>                                                            comment
#> 1                                                             <NA>
#> 2                                                             <NA>
#> 3                                                             <NA>
#> 4 There are too many empty drops (lambda of lower cluster: 0.9983)
#>   drops_outlier drops_empty drops_non_empty drops_empty_fraction
#> 1             0       16690             768                0.956
#> 2             0       12925             730                0.947
#> 3             0       13903            1376                0.910
#> 4             3          NA              NA                   NA
#>   concentration
#> 1            49
#> 2            59
#> 3           103
#> 4            NA
```

Now there's a bit more information in the results table. The *comment* column is used to store any additional information relating to the analysis and is fairly technical in nature; you can safely ignore it. The *success* column indicates whether or not the ddPCR run was successful in that particular well; notice how well `C06` was deemed a failure, and thus is not included the any subsequent analysis steps.

### Plot

The easiest way to visualize a ddPCR plate is using the `plot()` function.

``` r
plate %>% plot
```

![](vignettes/README-explore-post-4-1.png)

Notice well `C06` is grayed out, which means that it is a failed well. By default, failed wells have a grey background, and empty and outlier droplets are excluded from the plot.

You don't have to analyze a plate object before you can plot it - a ddPCR plate can be plotted at any time to show the data in it. If you plot a plate before analysing it, it'll show the raw data.

### Plotting parameters

There are many plotting parameters to allow you to create extremely customizable plots. Among the many parameters, there are three special categories of parameters that affect the visibility of droplets: `show_drops_*` is used to show/hide certain droplets, `col_drops_*` is used to set the colour of droplets, and `alpha_drops_*` is used to set the transparency of droplets (0 = transparent, 1 = opaque). The `*` can be replaced by the name of any droplet cluster (the available clusters can be obtained with `clusters(plate)` as mentioned earlier). For example, to show the outlier droplets in blue you would need to add the parameters `show_drops_outlier = TRUE, col_drops_outlier = "blue"`.

The following two plots show examples of how to use some plot parameters.

``` r
plate %>% plot(wells = "B01,B06", show_full_plate = TRUE,
               show_drops_empty = TRUE, col_drops_empty = "red",
               title = "Show full plate")
plate %>% plot(wells = "B01,B06", superimpose = TRUE,
               show_grid = TRUE, show_grid_labels = TRUE, title = "Superimpose")
```

<img src="vignettes/README-plotparams-1.png" title="" alt="" width="50%" /><img src="vignettes/README-plotparams-2.png" title="" alt="" width="50%" />

### Save your data

As was shown previously, you can use the `plate_meta()` function to retrieve a table with the results. If you want to save that table, you can use R's builtin `write.csv()` or `write.table()` functions.

You can also save a ddPCR plate object using `plate_save()`. This will create a single `.rds` file that contains an exact copy of the plate's current state, including all the data, attributes, and analysis progress of the plate. The resulting file can be loaded to restore the ddPCR object at a later time with `plate_load()`.

``` r
plate %>% save_plate("myplate")
from_file <- load_plate("myplate")
identical(plate, from_file)
#> [1] TRUE
rm(from_file)
```

### Plate parameters

Every ddPCR plate object has adjustable parameters associated to it. There are general parameters that apply to the plate as a whole, and each step has its own set of parameters that are used in that step. You can see all the parameters of a plate using the `params()` function

``` r
plate %>% params %>% str
#> List of 4
#>  $ GENERAL        :List of 3
#>   ..$ X_VAR         : chr "HEX"
#>   ..$ Y_VAR         : chr "FAM"
#>   ..$ DROPLET_VOLUME: num 0.00091
#>  $ REMOVE_FAILURES:List of 4
#>   ..$ TOTAL_DROPS_T       : num 5000
#>   ..$ NORMAL_LAMBDA_LOW_T : num 0.3
#>   ..$ NORMAL_LAMBDA_HIGH_T: num 0.99
#>   ..$ NORMAL_SIGMA_T      : num 200
#>  $ REMOVE_OUTLIERS:List of 2
#>   ..$ TOP_PERCENT: num 1
#>   ..$ CUTOFF_IQR : num 5
#>  $ REMOVE_EMPTY   :List of 1
#>   ..$ CUTOFF_SD: num 7
```

You can also view the parameters for a specific step or the value of a parameter. For example, to see the parameters used in the step that identifies failed wells, use

``` r
plate %>% params("REMOVE_FAILURES")
#> $TOTAL_DROPS_T
#> [1] 5000
#> 
#> $NORMAL_LAMBDA_LOW_T
#> [1] 0.3
#> 
#> $NORMAL_LAMBDA_HIGH_T
#> [1] 0.99
#> 
#> $NORMAL_SIGMA_T
#> [1] 200
```

You can also view or edit specific parameters. When identifying failed wells, one of the conditions for a successful run is to have at least 5000 droplets in the well (Bio-Rad claims that every well has 20000 droplets). If you know that your particular experiment had much less droplets than usual and as a result `ddpcr` thinks that all the wells are failures, you can change the setting

``` r
params(plate, "REMOVE_FAILURES", "TOTAL_DROPS_T")
#> [1] 5000
params(plate, "REMOVE_FAILURES", "TOTAL_DROPS_T") <- 1000
params(plate, "REMOVE_FAILURES", "TOTAL_DROPS_T")
#> [1] 1000
```

settype reset type

Adding your own type (separate vignette)
