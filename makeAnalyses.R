for (educ_level in c("Middle or Less", "Some High", "High School Graduate",
                     "Some College", "College Graduate")) {
  rmarkdown::render("main.Rmd", output_format = "github_document",
                    output_file = paste0(gsub(" ","_",educ_level),".md"),
                    params = list(Education = educ_level)
  )
}
