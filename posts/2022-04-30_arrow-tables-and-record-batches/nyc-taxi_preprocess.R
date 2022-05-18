library(arrow)

# location of this post
root <- here::here("posts/2022-04-30_arrow-tables-and-record-batches/")

# read the files from the s3 bucket
copy_files(
  from = s3_bucket("ursa-labs-taxi-data-v2"),
  to = "~/Datasets/nyc-taxi"
)

# # collate to a single Arrow table
# sep <- open_dataset(file.path(root, "nyc-taxi_2019-09"))
# arr <- sep$files |>
#   purrr::map(
#     ~ . |>
#       read_parquet() |>
#       record_batch()
#   )
# tab <- purrr::reduce(arr, concat_tables)
#
# # write as feather and as parquet
# write_feather(tab, file.path(root, "nyc-taxi_2019-09.feather"))
# write_parquet(tab, file.path(root, "nyc-taxi_2019-09.parquet"))
