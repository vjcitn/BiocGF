#train_test_id_split_list = list("attr_key"= "individual",
#                            "train"= c(train_ids,eval_ids),
#                            "test"= test_ids)
#
#train_valid_id_split_list = list("attr_key"="individual",
#                             train=train_ids, eval=eval_ids)

#training_args = list(
#    "num_train_epochs"= 0.9,
#    "learning_rate"= 0.000804,
#    "lr_scheduler_type"= "polynomial",
#    "warmup_steps"= 1812L,
#    "weight_decay"=0.258828,
#    "per_device_train_batch_size"= 12L,
#    "seed"= 73L)




#' returns instance of geneformer.Classifier
#' @note We pick up the Geneformer package frozen with BiocGF.
#' `token_dictionary.pkl` must be present in working dir
#' @param input_data_file character(1) path to a `.datasets` folder loadable by huggingface `datasets` module
#' @param output_directory character(1) folder that will be populated with fine tuning test and train outcome
#' resources.  For the heart failure example, 2.2 GB of results are produced, possibly inefficient owing to
#' caching practices.
#' @param output_prefix character(1) tag prepended  (or postfixed) to certain generated resources
#' @param split_id_list an R list() with components `attr_key`, `train` and `test`
#' @param classifier character(1) defaults to "cell", see sources of python modules for options (:-()
#' @param cell_state_dict an R list() of cell type tags, with 'name' corresponding to the
#' name used in the tokenized base data (h5ad or loom)
#' @param filter_data a list of e.g., cell type tags, that will be analyzed
#' @param training_args a list with such components as `num_train_epochs` and `learning_rate` -- look fo
#' authoritative doc
#' @param max_ncells integer(1)
#' @param freeze_layers integer(1) seek authoritative doc
#' @param num_crossval_splits integer(1)
#' @param forward_batch_size integer(1)
#' @param nproc integer(1) concerning parallelization
#' @param base_model_dir character(1) path to safetensors representation of model
#' @param val_split_id_list list() with elements `attr_key`, `train`, `eval`
#' @return a list with information on accuracy
#' @export
setup_and_run_Classifier = function(
   input_data_file,
   output_directory,
   output_prefix,
   split_id_list,
   classifier,
   cell_state_dict,
   filter_data,
   training_args,
   max_ncells,
   freeze_layers,
   num_crossval_splits,
   forward_batch_size,
   nproc,  # following are validation args
   base_model_dir,
   val_split_id_list) {
 proc = basilisk::basiliskStart(BiocGF:::gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function( input_data_file,
   output_directory,
   output_prefix,
   split_id_list,
   classifier,
   cell_state_dict,
   filter_data,
   training_args,
   max_ncells,
   freeze_layers,
   num_crossval_splits,
   forward_batch_size,
   nproc,
   base_model_dir,
   val_split_id_list) {
  l2rd = function(lis) reticulate::dict(lis)
print(l2rd(filter_data))
print(l2rd(cell_state_dict))
  dd = reticulate::import_from_path("geneformer", 
      path=system.file("python", "Geneformer", package="BiocGF"))
  cl_inst = dd$Classifier( classifier=classifier,
   cell_state_dict=l2rd(cell_state_dict),
   filter_data=l2rd(filter_data),
   training_args=l2rd(training_args),
   max_ncells=max_ncells,
   freeze_layers=freeze_layers,
   num_crossval_splits=num_crossval_splits,
   forward_batch_size=forward_batch_size,
   nproc=nproc)
  splid_dict = l2rd(split_id_list)
  cl_inst$prepare_data(
         input_data_file=input_data_file,
                output_directory=output_directory,
                output_prefix=output_prefix,
                split_id_dict=splid_dict)
#
# this part produces 'all.metrics'
#
  all.met = cl_inst$validate(model_directory = base_model_dir,
        prepared_input_data_file = file.path(output_directory,
          paste0(output_prefix, "_labeled_train.dataset")),
        id_class_dict_file = file.path(output_directory,
	  paste0(output_prefix, "_id_class_dict.pkl")),
        output_directory = output_directory,
        output_prefix = output_prefix,
        split_id_dict = l2rd(val_split_id_list))
#
# at this point we have 240710_geneformer_cellClassifier_darmanis_test in output_dir
# it has subfolders as at the end of this script
#
# next step is called "evaluate the model"
  dd$Classifier(classifier="cell",
                cell_state_dict = l2rd(cell_state_dict),
                forward_batch_size=forward_batch_size,
                nproc=nproc)
  all.met
},
   input_data_file=input_data_file,
   output_directory=output_directory,
   output_prefix=output_prefix,
   split_id_list=split_id_list,
  classifier=classifier,
   cell_state_dict=cell_state_dict,
   filter_data=filter_data,
   training_args=training_args,
   max_ncells=max_ncells,
   freeze_layers=freeze_layers,
   num_crossval_splits=num_crossval_splits,
   forward_batch_size=forward_batch_size,
   nproc=nproc,
   base_model_dir,
   val_split_id_list)
}

