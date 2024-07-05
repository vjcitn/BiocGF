#' expose safetensors infrastructure
#' @export
get_safet = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import("safetensors") # huggingface
  dd
  })
}

#' count number of weights in safetensors file
#' @param fn character(1) filename defaults to model.safetensors
#' @export
nwts_safet = function(fn="model.safetensors") {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function(fn) {
  st = reticulate::import("safetensors") # huggingface
  fref = st$safe_open(filename=fn, framework="pt")
  mkeys = fref$keys() 
  sum(sapply(mkeys, function(z) fref$get_tensor(z)$numel()))
  }, fn)
}
