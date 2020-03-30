gediDownloadFile <- function (url, outdir, overwrite, buffer_size, netrc)
{
  filename <- file.path(outdir, basename(url))
  if ((!overwrite) && file.exists(filename)) {
    message("Skipping this file, already downloaded!")
    return(0)
  }
  resume = paste0(filename, ".curltmp")
  if (file.exists(resume)) {
    resume_from = file.info(resume)$size
  }
  else {
    resume_from = 0
  }
  h = curl::new_handle()
  curl::handle_setopt(h, netrc = 1, netrc_file = netrc, resume_from = resume_from,
                      httpauth = 1,
                      userpwd = "femeunier:Jleconnaispas0")
  tryCatch({
    fileHandle = file(resume, open = "ab", raw = T)
    conn = curl::curl(url, handle = h, open = "rb")
    headers = rawToChar(curl::handle_data(h)$headers)
    total_size = as.numeric(gsub("[^ç]*Content-Length: ([0-9]+)[^ç]*",
                                 "\\1", x = headers, perl = T))
    while (TRUE) {
      message(sprintf("\rDownloading... %.2f/%.2fMB (%.2f%%)    ",
                      resume_from/1024/1024, total_size/1024/1024,
                      100 * resume_from/total_size), appendLF = FALSE)
      data = readBin(conn, what = raw(), n = 1024 * buffer_size)
      size = length(data)
      if (size == 0) {
        break
      }
      writeBin(data, fileHandle, useBytes = T)
      resume_from = resume_from + size
    }
    message(sprintf("\rDownloading... %.2f/%.2fMB (100%%)    ",
                    total_size/1024/1024, total_size/1024/1024))
    close(fileHandle)
    close(conn)
    file.rename(resume, filename)
    return(0)
  }, interrupt = function(e) {
    warning("\nDownload interrupted!!!")
    try(close(conn), silent = TRUE)
    try(close(fileHandle), silent = TRUE)
  }, finally = {
    try(close(conn), silent = TRUE)
    try(close(fileHandle), silent = TRUE)
  })
  return(-1)
}
