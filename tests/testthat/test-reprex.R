## https://github.com/tidyverse/reprex/issues/152
test_that("keep.source is TRUE inside the reprex()", {
  skip_on_cran()
  ret <- reprex(input = "getOption('keep.source')\n")
  expect_match(ret, "TRUE", all = FALSE)
})

test_that("reprex() works with code that deals with srcrefs", {
  skip_on_cran()
  ret <- reprex(
    input = "utils::getParseData(parse(text = 'a'))\n",
    advertise = FALSE
  )
  expect_known_output(print(ret), test_path("reference/srcref_reprex"))
})

## https://github.com/tidyverse/reprex/issues/183
test_that("reprex() doesn't leak files by default", {
  skip_on_cran()
  reprex(base::writeLines("test", "test.txt"), advertise = FALSE)
  ret <- reprex(base::readLines("test.txt"), advertise = FALSE)
  expect_match(ret, "cannot open file 'test.txt'", all = FALSE)
})

test_that("rmarkdown::render() context is trimmed from rlang backtrace", {
  skip_on_cran()
  input <- c(
    "f <- function() rlang::abort('foo')",
    "f()",
    "rlang::last_error()",
    "rlang::last_trace()"
  )
  ret <- reprex(input = input, advertise = FALSE)
  expect_false(any(grepl("tryCatch", ret)))
  expect_false(any(grepl("rmarkdown::render", ret)))
})

test_that("rlang::last_error() and last_trace() work", {
  skip_on_cran()

  input <- c(
    "f <- function() rlang::abort('foo')",
    "f()",
    "rlang::last_error()",
    "rlang::last_trace()"
  )
  ret <- reprex(input = input, advertise = FALSE)
  m <- match("rlang::last_error()", ret)
  expect_false(grepl("Error", ret[m + 1]))
  m <- match("rlang::last_trace()", ret)
  expect_false(grepl("Error", ret[m + 1]))
})

test_that("reprex() works even if user uses fancy quotes", {
  skip_on_cran()
  withr::local_options(list(useFancyQuotes = TRUE))
  # use non-default venue to force some quoted yaml to be written
  expect_error_free(reprex(1, venue = "R"))
})
