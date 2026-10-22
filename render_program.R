# render_program.R
files <- list.files('program', pattern = "\\.Rmd$", full.names = TRUE)
for (f in files) {
  rmarkdown::render(
    f,
    output_dir = '_site/program',   # 关键：输出到 _site/program
    output_file = gsub("\\.Rmd$", ".html", basename(f))
  )
}