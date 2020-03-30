gediDownload <- function (filepath, outdir = NULL, overwrite = FALSE, buffer_size = 512)
{
  if (is.null(outdir)) {
    outdir == tempdir()
  }
  rGEDI:::stopifnotMessage(`outdir is not a valid path` = rGEDI:::checkParentDir(outdir),
                   `overwrite is not logical` = rGEDI:::checkLogical(overwrite),
                   `buffer_size is not an integer` = rGEDI:::checkInteger(buffer_size))
  buffer_size = as.integer(buffer_size)
  netrc = rGEDI:::getNetRC(outdir)
  files <- filepath
  n_files = length(files)
  for (i in 1:n_files) {
    url = files[i]
    message("------------------------------")
    message(sprintf("Downloading file %d/%d: %s", i, n_files,
                    basename(url)))
    message("------------------------------")
    if (LianaGEDI::gediDownloadFile(url, outdir, overwrite, buffer_size,
                         netrc) == 0) {
      message("Finished successfully!")
    }
    else {
      stop(sprintf("File %s has not been downloaded properly!",
                   basename(url)))
    }
  }
}
