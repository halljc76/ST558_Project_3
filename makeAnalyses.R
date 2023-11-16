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
