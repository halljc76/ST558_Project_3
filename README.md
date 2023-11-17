## ST 558 Project 3: Analysis of Diabetes Data

**Group Members**: [Carter Hall](mailto:jchall6@ncsu.edu), [Autumn Locklear](mailto:alockle7@ncsu.edu)

### Description of Repository

The purpose of this repository is to serve as a central hub for our analysis on the `diabetes_binary_health_indicators_BRFSS2015.csv` dataset. We used this repository for collaboration and version control as we worked through an Exploratory Data Analysis and modeling project. This repo also serves as storage for the associated files.

### `R` Packages Used For Analysis

`library(readr)`
`library(dplyr)`
`library(tidyr)`
`library(ggplot2)`
`library(caret)`
`library(cowplot)`
`library(gridExtra)`
`library(caret)`

### Code for Reproducibility

for (educ_level in c("Middle or Less", "Some High", "High School Graduate",
                     "Some College", "College_Graduate")) {
  rmarkdown::render("./main.Rmd", output_file = paste0(tolower(gsub(" ", "_",
                                                                    x = educ_level)
  ),
  ".md"
  ), 
  params = list(Education = educ_level)
  )
}

### HTML Links of Generated Analyses

- [Analysis for Middle School or Less](middle_or_less.html)
- [Analysis for Some High School](some_high.html)
- [Analysis for High School Graduate](high_school_graduate.html)
- [Analysis for Some College](some_college.html)
- [Analysis for College Graduate](college_graduate.html)