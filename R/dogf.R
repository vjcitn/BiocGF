# this will tokenize a loom file according to geneformer
#too = import("tokenizer")
#ttt = too$TranscriptomeTokenizer()
#ttt$tokenize_data(data_directory=".", output_directory="useR", output_prefix="tbyr")
#vv2 = dd$load_from_disk("useR/tbyr.dataset")
#str(vv2[[0]])
#names(ttt)
#gtmap = ttt$gene_token_dict

#' tickle basilisk installation
#' @note Intent is to hand back a python reference, not endorsed in basilisk.
#' Use better insulation in production.
#' @import basilisk reticulate
#' @examples
#' if (interactive()) {
#'  cur = getwd()
#'  td = tempdir()
#'  setwd(td)
#'  download.file(panc_tok_zip_url(), "panc_hfds.zip")
#'  unzip("panc_hfds.zip")
#'  ds = getgf()
#'  ref = ds$load_from_disk("panc_hfds/tbyr.dataset")
#'  print(ref)
#'  setwd(cur)
#' }
#' @export
getgf = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import("datasets") # huggingface
  dd
  })
}

#' give URL for 'dataset' corresponding to tokenization of pancreas data
#' @export
panc_tok_zip_url = function()
"https://mghp.osn.xsede.org/bir190004-bucket01/BiocGFdata/panc_hfds.zip"
