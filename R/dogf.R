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
#'  pa = get_panc_tok_path()
#'  unzip(pa)  # destination = "."
#'  ds = getgf() # get python module
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

#' give URL for 'loom' file for pancreas data
#' @export
panc_loom_url = function()
"https://mghp.osn.xsede.org/bir190004-bucket01/BiocGFdata/pancreas_scib.loom"

#' retrieve or place a zipfile with tokenization dataset for Grun/Muraro's pancreas study in BiocFileCache
#' @import BiocFileCache
#' @param cache cache instance likely inheriting from BiocFileCache::BiocFileCache
#' @note A loom file was distributed at
#' \url{https://figshare.com/articles/dataset/Data_used_for_demo_of_the_code_accompanying_the_i_Assessing_the_limits_of_zero-shot_foundation_models_in_single-cell_biology_i_paper_/24747228} under
#' data/datasets/geneformer/pancreas_scib.  The relevant publication
#' seems to be
#'  \url{https://pubmed.ncbi.nlm.nih.gov/27345837/}, GSE81076, etc.
#' @return character path to zip file
#' @export
get_panc_tok_path = function(cache = BiocFileCache::BiocFileCache()) {
  src = panc_tok_zip_url()
  q = BiocFileCache::bfcquery(cache, "panc_hfds.zip")
  nans = nrow(q)
  if (nans >= 1) {
    q = q[nans,]
    return(q$rpath)  # quietly return last
    }
  p = BiocFileCache::bfcadd(cache, rname=src,
    action="copy", download=TRUE)
  p
  }
  
#' use import_from_python in reticulate to get the geneformer modules
#' @export
get_gf_python = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import_from_path("geneformer", path=system.file("python", "Geneformer", package="BiocGF"))
  dd
  })
}

#' retrieve or place a loom file for Grun/Muraro's pancreas study in BiocFileCache
#' @import BiocFileCache anndata
#' @param cache instance of BiocFileCache::BiocFileCache()
#' @note A loom file was distributed at
#' \url{https://figshare.com/articles/dataset/Data_used_for_demo_of_the_code_accompanying_the_i_Assessing_the_limits_of_zero-shot_foundation_models_in_single-cell_biology_i_paper_/24747228} under
#' data/datasets/geneformer/pancreas_scib.  The relevant publication
#' seems to be
#'  \url{https://pubmed.ncbi.nlm.nih.gov/27345837/}, GSE81076, etc.
#' @return character path to loom file
#' @examples
#' pa = get_panc_loom_path()
#' proc = basilisk::basiliskStart(BiocGF:::gfenv)
#' x = basilisk::basiliskRun(proc, function() {
#'  anndata::read_loom(pa)
#' })
#' basilisk::basiliskStop(proc)
#' x
#' @export
get_panc_loom_path = function(cache = BiocFileCache::BiocFileCache()) {
  src = panc_loom_url()
  q = BiocFileCache::bfcquery(cache, "pancreas_scib.loom")
  nans = nrow(q)
  if (nans >= 1) {
    q = q[nans,]
    return(q$rpath)  # quietly return last
    }
  p = BiocFileCache::bfcadd(cache, rname=src,
    action="copy", download=TRUE)
  p
  }

#' return handle to huggingface datasets module
#' @export
get_dsref = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import("datasets") # huggingface
  dd
  })
}

#' return handle to anndata
#' @export
get_adref = function() {
 proc = basilisk::basiliskStart(gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import("anndata") # huggingface
  dd
  })
}

#' retrieve or place the model.safetensors for Geneformer (6L?) in cache, zipped
#' @import BiocFileCache 
#' @param cache instance of BiocFileCache::BiocFileCache()
#' @note A README.txt is included in the zip file
#' @return character path to zip file once cached
#' @examples
#' pa = get_gf_safetensors()
#' td = tempdir()
#' unzip(pa, exdir=td)
#' nwts_safet(file.path(td, "GF_safetensors", "model.safetensors"))
#' st = get_safet() # not standard, hands live python ref
#' oo = st$safe_open(file.path(td, "GF_safetensors", "model.safetensors"), "pt")
#' mk = oo$keys()
#' length(mk)
#' head(sapply(mk, function(z) oo$get_tensor(z)$shape))
#' @export
get_gf_safetensors = function(cache = BiocFileCache::BiocFileCache()) {
  src = "https://mghp.osn.xsede.org/bir190004-bucket01/BiocGFdata/GF_safetensors.zip"
  q = BiocFileCache::bfcquery(cache, "GF_safetensors.zip")
  nans = nrow(q)
  if (nans >= 1) {
    q = q[nans,]
    return(q$rpath)  # quietly return last
    }
  p = BiocFileCache::bfcadd(cache, rname=src,
    action="copy", download=TRUE)
  p
  }
