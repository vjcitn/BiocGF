#' tokenize a loom file
#' @param loompath character(1) path to loom file
#' @param output_directory character(1) defaults to tempdir()
#' @param output_prefix character(1) defaults to "loomtoks"
#' @note The python functionality calls for dirname(loompath).
#' @examples
#' lp = get_panc_loom_path()
#' gf_tokenize_loom(lp)
#' dir(tempdir())
#' @export
gf_tokenize_loom = function(loompath, output_directory = tempdir(),
    output_prefix = "loomtoks") {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function(loompath, output_directory, output_prefix) {
  dd = reticulate::import_from_path("geneformer", path=system.file("python", "Geneformer", package="BiocGF"))
#
# we want to preserve all cell metadata, so must read the loom
#
  thel = anndata::read_loom(loompath)
  z = lapply(names(thel$obs), force)
  names(z) = names(thel$obs)
  cmeta = reticulate::dict(z)
  tt = dd$tokenizer$TranscriptomeTokenizer(cmeta)
  tt$tokenize_data(data_directory = dirname(loompath),
     output_directory = output_directory,
     output_prefix = output_prefix)
  ds = reticulate::import("datasets")
  ds$load_from_disk(file.path(output_directory, paste0(output_prefix, ".",
         "dataset")))
  }, loompath, output_directory, output_prefix)
}

