for (educ_level in c("High School Graduate",
                     "Some College", "College Graduate")) {
  rmarkdown::render("main.Rmd", output_format = "github_document",
                    output_file = paste0(gsub(" ","_","High School Graduate"),".md"),
                    params = list(Education = "High School Graduate")
  )
}
