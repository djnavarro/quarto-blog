# refs:
#
# data source: https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors
# useful history: https://en.wikipedia.org/wiki/History_of_Crayola_crayons
# original post: http://www.datapointed.net/2010/01/crayola-crayon-color-chart/ (Stephen Von Worley)
#                http://www.datapointed.net/2010/10/crayola-color-chart-rainbow-style/
# mastodon post: https://mas.to/@kims/109525496705672156 (Kim Scheinberg)
# notes on scraping: https://ivelasq.rbind.io/blog/politely-scraping/ (Isabella Velásquez)

library(ggplot2)
library(colorspace)

# politely scrape the tables from the wikipedia page
url <- "https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors"
raw <- url |>
  polite::bow() |>
  polite::scrape() |>
  rvest::html_nodes("table.wikitable")

# extract the first table and convert it to a data frame: at this point
# we can visually inspect to see if it looks right. it mostly does but
# hm... colors haven't appeared, only those that had a listing on the web
tbl <- raw |>
  purrr::pluck(1) |>
  rvest::html_table()

# tidy up the rest of the table, keeping the listing for later audit
# when we fill the real colours in but dropping other columns
crayola <- tbl |>
  janitor::clean_names() |>
  dplyr::select(
    color,
    name,
    listed = hexadecimal_in_their_website_depiction_b,
    years = years_in_production_2
  )

# pull the xml nodes from the first table that correspond to table data <td>
cells <- raw[[1]] |>
  rvest::html_elements("td")

# convert those nodes to text. this doesn't solve the problem because it only
# gets the text and we lose the styling, but notice that the colour name is
# captured, and we know the cell with the info we want is always the one left
# of (i.e. preceding) the one containing the name.
cell_text <- cells |>
  rvest::html_text() |>
  stringr::str_remove_all("\n$")

# these are the indices of the cells containing the css that we need
ind <- which(cell_text %in% crayola$name) - 1

# use rvest to extract the style attribute, then stringr to pull the hex
background <- cells[ind] |>
  rvest::html_attr("style") |>
  stringr::str_extract("#[0-9ABCDEF]{6}")

# insert into the table, inspect and compare the color column to the listed
# column. where listings are available they seem to match, so now we'll drop
# the listing column
crayola$color <- background

crayola <- crayola |>
  dplyr::select(color, name, years) |>

  # clean up the years column
  dplyr::mutate(
    years = years |>
      stringr::str_remove_all(" ") |>
      stringr::str_remove_all("\\[.\\]") |>
      stringr::str_remove_all("circa") |>
      stringr::str_replace_all("present", "2022") |>
      stringr::str_replace_all("2021,2022", "2021-2022"),
  ) |>

  # some colours appear in two contiguous intervals separated by
  # commas: split those into separate columns first...
  tidyr::separate(
    col = years,
    into = c("years_1", "years_2"),
    sep = ",",
    fill = "right"
  ) |>

  # ...pivot longer so that each contiguous interval is a row
  tidyr::pivot_longer(
    cols = starts_with("years_"),
    names_prefix = "years_",
    names_to = "interval",
    values_to = "years"
  ) |>

  # drop empty rows for all those colours that didn't have a second
  # contiguous interval
  dplyr::filter(!is.na(years)) |>

  # now split the "1935-1992" interval into two columns
  tidyr::separate(
    col = years,
    into = c("year_started", "year_ended"),
    fill = "right"
  ) |>

  # if only a single year was given use it for the year end and the year start,
  # and coerce strings to integers as appropriate
  dplyr::mutate(
    id = dplyr::row_number(),
    year_ended = dplyr::if_else(is.na(year_ended), year_started, year_ended),
    interval = as.integer(interval),
    year_started = as.integer(year_started),
    year_ended = as.integer(year_ended)
  )

# transformer function to map each year in an interval to a row in a tibble
unpack_row <- function(id, color, name, interval, year_started, year_ended) {
  # https://en.wikipedia.org/wiki/CIELUV
  HSV <- coords(as(hex2RGB(color), "HSV"))
  LUV <- coords(as(hex2RGB(color), "LUV"))
  tibble::tibble(
    id = id,
    color = color,
    hue = HSV[1, "H"],
    sat = HSV[1, "S"],
    val = HSV[1, "V"],
    lightness = LUV[1, "L"],
    chroma_u = LUV[1, "U"],
    chroma_v = LUV[1, "V"],
    name = name,
    year = year_started:year_ended
  )
}

# apply it to each row to end up with a tidy tibble
crayola <- crayola |>
  dplyr::group_by(id) |>
  purrr::pmap_dfr(unpack_row) |>
  dplyr::arrange(year, color) |>
  dplyr::mutate(id = dplyr::row_number())

# write a csv just in case
folder <- here::here("posts", "2022-12-18_crayola-crayon-colours")
readr::write_csv(crayola, fs::path(folder, "crayola.csv"))

# plot specification in ggplot2
pic <- crayola |>
  dplyr::mutate(
    ord = chroma_u/2 + hue, # omg such a hack
    color = forcats::fct_reorder(color, ord)) |>
  ggplot(aes(
    x = year,
    group = color,
    fill = color
  )) +
  geom_bar(
    position = "fill",
    linetype = "blank",
    width = 1,
    show.legend = FALSE
  ) +
  theme_void() +
  scale_fill_identity() +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  NULL

# save the image
ggsave(
  filename = fs::path(folder, "crayola.png"),
  device = ragg::agg_png,
  plot = pic,
  width = 6000,
  height = 6000,
  units = "px"
)
