
<!-- README.md is generated from README.Rmd. Please edit that file -->

# syncons

<!-- badges: start -->
<!-- badges: end -->

The goal of `syncons` is to support massive construction of synthetic
communities (SynComs) with 24-, 96- and 384-well plates.

## Installation

You can install the development version of `syncons` like so:

``` r
install.packages("pak")
pak::pak("gaospecial/syncons")
```

Now you can use this package.

``` r
library("syncons")
```

## Layout of SynComs in a plate

A 24-well plate can be used to construct 16 different SynComs with 4
strains.

``` r
one_plate(24, return_layout = TRUE)
#> # A tibble: 4 × 5
#>   row   `1`         `2`      `3`      `4`    
#>   <chr> <chr>       <chr>    <chr>    <chr>  
#> 1 A     S1/S2/S3/S4 S1/S3/S4 S2/S3/S4 "S3/S4"
#> 2 B     S1/S2/S3    S1/S3    S2/S3    "S3"   
#> 3 C     S1/S2/S4    S1/S4    S2/S4    "S4"   
#> 4 D     S1/S2       S1       S2       ""
```

A 96-well plate can be used to construct 64 different SynComs with 6
strains.

``` r
one_plate(96, return_layout = TRUE)
#> # A tibble: 8 × 9
#>   row   `1`               `2`            `3`       `4`   `5`   `6`   `7`   `8`  
#>   <chr> <chr>             <chr>          <chr>     <chr> <chr> <chr> <chr> <chr>
#> 1 A     S1/S2/S3/S4/S5/S6 S1/S2/S4/S5/S6 S1/S3/S4… S1/S… S2/S… S2/S… S3/S… "S4/…
#> 2 B     S1/S2/S3/S4/S5    S1/S2/S4/S5    S1/S3/S4… S1/S… S2/S… S2/S… S3/S… "S4/…
#> 3 C     S1/S2/S3/S4/S6    S1/S2/S4/S6    S1/S3/S4… S1/S… S2/S… S2/S… S3/S… "S4/…
#> 4 D     S1/S2/S3/S4       S1/S2/S4       S1/S3/S4  S1/S4 S2/S… S2/S4 S3/S4 "S4" 
#> 5 E     S1/S2/S3/S5/S6    S1/S2/S5/S6    S1/S3/S5… S1/S… S2/S… S2/S… S3/S… "S5/…
#> 6 F     S1/S2/S3/S5       S1/S2/S5       S1/S3/S5  S1/S5 S2/S… S2/S5 S3/S5 "S5" 
#> 7 G     S1/S2/S3/S6       S1/S2/S6       S1/S3/S6  S1/S6 S2/S… S2/S6 S3/S6 "S6" 
#> 8 H     S1/S2/S3          S1/S2          S1/S3     S1    S2/S3 S2    S3    ""
```

A 384-well plate can be used to construct 256 different SynComs with 8
strains.

``` r
one_plate(384, return_layout = TRUE)
#> # A tibble: 16 × 17
#>    row   `1`   `2`   `3`   `4`   `5`   `6`   `7`   `8`   `9`   `10`  `11`  `12` 
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 A     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  2 B     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  3 C     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  4 D     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  5 E     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  6 F     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  7 G     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#>  8 H     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S5 S2/S… S2/S… S2/S… S2/S5
#>  9 I     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#> 10 J     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#> 11 K     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#> 12 L     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S6 S2/S… S2/S… S2/S… S2/S6
#> 13 M     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S2/S… S2/S… S2/S… S2/S…
#> 14 N     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S7 S2/S… S2/S… S2/S… S2/S7
#> 15 O     S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S… S1/S8 S2/S… S2/S… S2/S… S2/S8
#> 16 P     S1/S… S1/S… S1/S… S1/S2 S1/S… S1/S3 S1/S4 S1    S2/S… S2/S3 S2/S4 S2   
#> # ℹ 4 more variables: `13` <chr>, `14` <chr>, `15` <chr>, `16` <chr>
```

## Generation of sample tables

Support we have eight strains and want to construct a series of SynComs
with all the possible combinations.

``` r
strains = paste0("S", 1:8)
assign_plate(strains, plate_type = "96")
#> # A tibble: 256 × 2
#>    combination_id combination      
#>    <chr>          <chr>            
#>  1 P1A1           S1/S2/S3/S4/S5/S6
#>  2 P1B1           S1/S2/S3/S4/S5   
#>  3 P1C1           S1/S2/S3/S4/S6   
#>  4 P1D1           S1/S2/S3/S4      
#>  5 P1E1           S1/S2/S3/S5/S6   
#>  6 P1F1           S1/S2/S3/S5      
#>  7 P1G1           S1/S2/S3/S6      
#>  8 P1H1           S1/S2/S3         
#>  9 P1A2           S1/S2/S4/S5/S6   
#> 10 P1B2           S1/S2/S4/S5      
#> # ℹ 246 more rows
```

## Generation of supplementary information

This is for Bio-Protocol submission.

``` r
strains = paste0("S", 1:11)
sheets = list(
  sheet1 = assign_plate(strains[1:4]),
  sheet2 = assign_plate(strains[1:5]),
  sheet3 = assign_plate(strains[1:6], plate_type = "96"),
  sheet4 = assign_plate(strains[1:7], plate_type = "96"),
  sheet5_1 = assign_plate(strains[1:8], plate_type = "96"),
  sheet5_2 = assign_plate(strains[1:8], plate_type = "384"),
  sheet6_1 = assign_plate(strains[1:9], plate_type = "96"),
  sheet6_2 = assign_plate(strains[1:9], plate_type = "384"),
  sheet7 = assign_plate(strains[1:10], plate_type = "384"),
  sheet8 = assign_plate(strains[1:11], plate_type = "384")
)

openxlsx::write.xlsx(sheets, file = "Sheets.xlsx")
```
