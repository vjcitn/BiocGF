#' work with a template python script to illustrate mask substitution by a BERT model
#' @param phrase character(1) a string with `[MASK]` ending with a `.`.
#' @param decode logical(1) if TRUE, decoding is conducted; otherwise
#' a python reference is handed back
#' @examples
#' usebert()
#' @export
usebert = function(phrase="The capital of Spain is [MASK].", decode=TRUE) {
 tmp = readLines(system.file("python", "templates", "bmlm.template", package="BiocGF"))
 todo = gsub("%%ONEMASKPHRASE%%", phrase, tmp)
 tf = tempfile()
 writeLines(todo, tf)
 proc = basilisk::basiliskStart(BiocGF:::gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function(path, decode) {
  ans = reticulate::py_run_file(path)
  if (!decode) return(ans)
  ans$tokenizer$decode(ans$predicted_token_id)
  }, path=tf, decode=decode)
}
 
#' work with a template python script to illustrate mask substitution by a BERT model,
#' and use the pipeline unmasker to produce a list of scored substitutions
#' @param phrase character(1) a string with `[MASK]` ending with a `.`.
#' @examples
#' usebert_pipeline()
#' @export
usebert_pipeline = function(phrase="The capital of Spain is [MASK].") {
 tmp = readLines(system.file("python", "templates", "bmlmpipe.template", package="BiocGF"))
 todo = gsub("%%ONEMASKPHRASE%%", phrase, tmp)
 tf = tempfile()
 writeLines(todo, tf)
 proc = basilisk::basiliskStart(BiocGF:::gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function(path,phrase) {
  um = reticulate::py_run_file(path, local=TRUE)
  um$unmasker$`__call__`(phrase)
  }, path=tf,phrase=phrase)
}
 
