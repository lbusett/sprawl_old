#' @title migrate "virtual rasters" to a new location
#' @description function allowing to update the paths contained in "virtual rasters"
#'   such as GDAL VRTs or `R` rasterStacks "pointing" to files on disk in the case that
#'   the corresponding files on disk are moved.
#' @param in_rast `character` full file path of an `RData` or `vrt` file
#' @param new_path `character` new path were the corresponding files are now located. If NULL,
#'   a file selector is opened allowing to interactively choose the new folder, Default: NULL
#' @param out_file `character` full path for the new `RData` or `vrt` file to be saved.
#'   If NULL, the new file is built nby adding "_new" to the basename of the old one.
#'   If == "overwrite", the old file is overwritten.  Default: NULL
#' @return `character` path to the new "vrt" or "RData" file giving access to the raster
#'   files
#' @details DETAILS
#' @examples
#' \dontrun{
#'  # suppose you had a gdal vrt file "pointing" to tiff files originally located in
#'  # "/home/mypath/myfolder", and you successively moved them to "/home/mypath/mynewfolder"
#'  # and you want to update the vrt file so that it keeps working
#'
#'  #TODO (Remove the # after uploading a test dataset on sprawl.data)
#'  #old_vrt  <- "/home/mypath/myfolder/myvrt.vrt
#'  #new_path <- "/home/mypath/mynewfolder"
#'  #new_vrt  <- migrate_virtrast(old_vrt, new_path)
#'  #new_vrt
#'  #raster::stack(new_vrt)
#' }
#' @rdname migrate_virtrast
#' @export
#' @importFrom raster nlayers
#' @importFrom stringr str_split_fixed
#' @importFrom tools file_ext file_path_sans_ext
#' @author Lorenzo Busetto, phD (2017) <lbusett@gmail.com>

migrate_virtrast <- function(in_rast,
                             new_path,
                             out_file = NULL) {
  UseMethod("migrate_virtrast")
}

#   ____________________________________________________________________________
#   Fallback method                                                         ####

#' @method migrate_virtrast default
#' @export
migrate_virtrast.default  <- function(in_rast,
                                      new_path,
                                      out_file = NULL) {
  call <- match.call()
  stop("migrate_virtrast --> ", call[[2]], " is not a `RData` or `GDAL vrt` file. Aborting !")
}

#' @method migrate_virtrast character
#' @export

migrate_virtrast.character  <- function(in_rast,
                                        new_path  = NULL,
                                        out_file = NULL) {
  call <- match.call()

  if (!file.exists(in_rast)) stop("migrate_virtrast --> ", call[[2]], " does not exist on
                                  your system. Aborting !")

  if (is.null(new_path)) {

    new_path <- tcltk::tk_choose.dir(default = "",
                                    caption = "Select folder containing the raster files")
    if (is.na(new_path)) {
      stop("migrate_virtrast --> User selected to quit. Aborting !")
    }
  }
  #   ____________________________________________________________________________
  #   If input file is a gdal vrt, substitute find the lines corresponding    ####
  #   to file paths and replace folder na,e with `new_path`

  if (tools::file_ext(in_rast) == "vrt") {
    file_in <- readLines(test)
    for (line in (seq_along(file_in))) {
      line_i    <- file_in[line]
      is_source <- grep("SourceFilename", line_i )
      if (length(is_source) != 0) {
        old_file <- stringr::str_split_fixed(stringr::str_split_fixed(line_i, ">" ,2)[2], "<" ,2)[1]
        new_file <- file.path(new_path, basename(old_file))
        file_in[line] <- gsub(old_file, new_file, file_in[line])
      }
    }
    if (is.null(out_file)) {
      out_file <- paste0(tools::file_path_sans_ext(in_rast), "_new.vrt")
    } else {
      if (out_file == "overwrite") {
        out_file <- in_rast
      }
    }
    writeLines(file_in, out_file)
    return(out_file)
  } else {

    #   ____________________________________________________________________________
    #   If input file is a RData file, open it as a rasterStack, then substitute ####
    #   paths in the layer names

    if (tools::file_ext(in_rast) == "RData") {
      rrast_in <- try(get(load(in_rast)))
      if (!inherits(rrast_in, "Raster")) {
        stop("migrate_virtrast --> ", call[[2]], " does not appear to be linked to a
             Raster object. Aborting !")
      } else {
        for (band in seq_len(raster::nlayers(rrast_in))) {
          old_file <- rrast_in[[band]]@file@name
          new_file <- file.path(new_path, basename(old_file))
          rrast_in[[band]]@file@name <- new_file
        }
        if (is.null(out_file)) {
          out_file <- paste0(tools::file_path_sans_ext(in_rast), "_new.RData")
        } else {
          if (out_file == "overwrite") {
            out_file <- in_rast
          }
        }
        save(rrast_in, file = out_file)
        return(out_file)
      }
    }
  }
}
