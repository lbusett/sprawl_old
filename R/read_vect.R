#' @title read a vector spatial file to R
#' @description function for easily opening a ESRI shapefile (or other OGR compatible vector file)
#' by simply specifying its filename
#'
#' @param shp_file `character` Filename of ESRI shapefile to be opened
#' @param as_sp   `logical` If TRUE, the opened object is automatically converted to `sp` format.
#' Otherwise, an `sf` object is returned. Default: FALSE
#' @param ... other arguments to be passed to[sf::st_read]
#'
#' @return `sf` or `sp` object (depending on `as_sp` setting)
#' @details simple wrapper around `sf::read_sf`, with some checks on inputs and possibility of
#' automatic re-casting to `*sp` objects
#' @export
#' @importFrom sf read_sf
#' @examples \dontrun{
#' library(sprawl.data)
#' # open a shapefile as a `sf` object
#'  shp_file = system.file("extdata","lc_polys.shp", package = "sprawl.data")
#'  read_vect(shp_file)
#'
#' # open a shapefile as a `sp` object
#'  shp_file = system.file("extdata","lc_polys.shp", package = "sprawl.data")
#'  read_vect(shp_file, as_sp = TRUE)
#'}
#'@seealso
#'  \code{\link[sf]{read_sf}}
#' @rdname read_vect
#' @export
#' @importFrom sf read_sf
#'
read_vect = function(shp_file, as_sp = FALSE, ...){
  if (!file.exists(shp_file)) {
    stop("read_vect --> Input file doesn't exist on your system ! Aborting !")
  }
  chk <- get_spatype(shp_file)
  if (chk == "vectfile") {
    shp <- sf::read_sf(shp_file, ...)
    if (as_sp) {
      shp <- as(shp, "Spatial")
    }
    return(shp)
  } else {
    stop("`shp_file` deosn't appear to correspond to a valid vector file ! Aborting !")
  }
}
