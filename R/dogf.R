# this will tokenize a loom file according to geneformer
#too = import("tokenizer")
#ttt = too$TranscriptomeTokenizer()
#ttt$tokenize_data(data_directory=".", output_directory="useR", output_prefix="tbyr")
#vv2 = dd$load_from_disk("useR/tbyr.dataset")
#str(vv2[[0]])
#names(ttt)
#gtmap = ttt$gene_token_dict

#' tickle basilisk installation
#' @import basilisk reticulate
#' @export

getgf = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import("datasets") # huggingface
  dd
  })
}
