library(BiocGF)
#' returns instance of geneformer.Classifier
#' @note We pick up the Geneformer package frozen with BiocGF.
#' `token_dictionary.pkl` must be present in working dir
#' @export
get_Classifier = function() {
 proc = basilisk::basiliskStart(BiocGF:::gfenv)
 on.exit(basilisk::basiliskStop(proc))
 basilisk::basiliskRun(proc, function() {
  dd = reticulate::import_from_path("geneformer", 
      path=system.file("python", "Geneformer", package="BiocGF"))
  dd$Classifier
  })
}

# this works but cl_inst has intricate inputs
# myd = reticulate::dict(list(state_key="batch", states="all"))
# cl = get_Classifier()
# cl_inst = cl(classifier="cell", cell_state_dict=myd)

# the output folder will contain lots of stuff

#exouser@ving3xl:/media/volume/boot-vol-vince_12apr$ ls vjcoutput2
#240704_geneformer_cellClassifier_cm_classifier_test  cm_classifier_test_labeled_train.dataset
#cm_classifier_test_conf_mat.pdf			     cm_classifier_test_pred.pdf
#cm_classifier_test_id_class_dict.pkl		     cm_classifier_test_pred_dict.pkl

# under the *classifier_test

# exouser@ving3xl:/media/volume/boot-vol-vince_12apr$ ls vjcoutput2/*test/*
# vjcoutput2/240704_geneformer_cellClassifier_cm_classifier_test/cm_classifier_test_eval_metrics_dict.pkl
# 
# vjcoutput2/240704_geneformer_cellClassifier_cm_classifier_test/ksplit1:
# checkpoint-7020  cm_classifier_test_pred_dict.pkl  config.json	model.safetensors  training_args.bin

# here the model.safetensors has the 10.3 million parameters "retuned"?  well, it
# has 10.26 million parameters, while Geneformer/model.safetensors has 10.29 million ...
# could it be that we are using a 6L vs 12L ?????

#cm_classifier_test_labeled_test.dataset		     cm_classifier_test_test_metrics_dict.pkl

#> unique(darpok2$donor)
#[1] 6 3 4 7 2 5 1 8
#> unique(darpok2$cell.type)
#[1] "oligodendrocytes"  "hybrid"            "astrocytes"       
#[4] "OPC"               "microglia"         "neurons"          
#[7] "endothelial"       "fetal_quiescent"   "fetal_replicating"
#> unique(darpok2$tissue)
#[1] "cortex"      "hippocampus"
#> table(darpok2$tissue, darpok2$donor)
#             
#                1   2   3   4   5   6   7   8
#  cortex       57   4  63  24  77  33  38 134
#  hippocampus   0   0   0   0   0  25  11   0



output_prefix = "darmanis_test"
output_dir = "/media/volume/boot-vol-vince_12apr/vjcjul10dout_darm"
model_dir_30M = "/media/volume/boot-vol-vince_12apr/Geneformer"
if (!dir.exists(output_dir)) dir.create(output_dir)

#filter_data_dict = list(cell.type = c("Cardiomyocyte1",
#          "Cardiomyocyte2", "Cardiomyocyte3"))
filter_data_dict = list(cell.type = c("oligodendrocytes", "hybrid", "astrocytes", "OPC", "microglia", 
"neurons", "endothelial", "fetal_quiescent", "fetal_replicating"))

training_args = list(
    "num_train_epochs"= 0.9,
    "learning_rate"= 0.000804,
    "lr_scheduler_type"= "polynomial",
    "warmup_steps"= 1812L,
    "weight_decay"=0.258828,
    "per_device_train_batch_size"= 12L,
    "seed"= 73L)

#' returns instance of geneformer.Classifier
#' @note We pick up the Geneformer package frozen with BiocGF.
#' `token_dictionary.pkl` must be present in working dir
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
                forward_batch_size=50L,
                nproc=4L)
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


#cl = get_Classifier()
myd = list(state_key="cell.type", states="all")
#

#train_ids = c("1447", "1600", "1462", "1558", "1300", "1508", "1358", "1678", "1561", "1304", "1610", "1430", "1472", "1707", "1726", "1504", "1425", "1617", "1631", "1735", "1582", "1722", "1622", "1630", "1290", "1479", "1371", "1549", "1515")
#eval_ids = c("1422", "1510", "1539", "1606", "1702")
#test_ids = c("1437", "1516", "1602", "1685", "1718")

#> dput(unique(darpok2$cell.type))
#c("oligodendrocytes", "hybrid", "astrocytes", "OPC", "microglia", 
#"neurons", "endothelial", "fetal_quiescent", "fetal_replicating"
#)
#> dput(unique(darpok2$donor))
#c(6, 3, 4, 7, 2, 5, 1, 8)
#> dput(unique(darpok2$tissue))
#c("cortex", "hippocampus")

train_ids = c(6L, 3L, 4L, 7L, 2L)
eval_ids = c(5L, 1L)
test_ids = c(1L, 8L)


#
train_test_id_split_list = list("attr_key"= "donor",
                            "train"= c(train_ids,eval_ids),
                            "test"= test_ids)

train_valid_id_split_list = list("attr_key"= "donor",
                            "train"= c(train_ids,eval_ids),
                            "eval"= test_ids)

cl_inst = setup_and_run_Classifier(
  input_data_file="/home/exouser/newdarmtok/h5adtoks.dataset/",
  output_directory=output_dir,
  output_prefix=output_prefix,
  split_id_list=train_test_id_split_list,
  classifier="cell", cell_state_dict=myd,
  filter_data=filter_data_dict, training_args = training_args,
  max_ncells=6000L, freeze_layers=2L, num_crossval_splits=1L,
  forward_batch_size=100L, nproc=4L, base_model_dir=model_dir_30M,
  val_split_id_list = train_valid_id_split_list)

#
## Example input_data_file: https://huggingface.co/datasets/ctheodoris/Genecorpus-30M/tree/main/example_input_files/cell_classification/disease_classification/human_dcm_hcm_nf.dataset
#cc.prepare_data(input_data_file="/media/volume/boot-vol-vince_12apr/human_dcm_hcm_nf.dataset",
#                output_directory=output_dir,
#                output_prefix=output_prefix,
#                split_id_dict=train_test_id_split_dict)
#
#
## In[5]:
#
#
#train_valid_id_split_dict = {"attr_key": "individual",
#                            "train": train_ids,
#                            "eval": eval_ids}

#validate = function(base_model_dir,
#   prepared_input_path,
#   val_id_class_dict_path,
#   val_output_path,
#   val_output_prefix,
#   val_split_id_list) {
   
#
## 6 layer Geneformer: https://huggingface.co/ctheodoris/Geneformer/blob/main/model.safetensors
#all_metrics = cc.validate(model_directory=MODEL_DIR,
#                          prepared_input_data_file=f"{output_dir}/{output_prefix}_labeled_train.dataset",
#                          id_class_dict_file=f"{output_dir}/{output_prefix}_id_class_dict.pkl",
#                          output_directory=output_dir,
#                          output_prefix=output_prefix,
#                          split_id_dict=train_valid_id_split_dict)
#                          # to optimize hyperparameters, set n_hyperopt_trials=100 (or alternative desired # of trials)
#
#
## ### Evaluate the model
#
## In[1]:
#
#
#cc = Classifier(classifier="cell",
#                cell_state_dict = {"state_key": "disease", "states": "all"},
#                forward_batch_size=200,
#                nproc=16)
#
#
## In[2]:
#
#
#all_metrics_test = cc.evaluate_saved_model(
#        model_directory=f"{output_dir}/{datestamp_min}_geneformer_cellClassifier_{output_prefix}/ksplit1/",
#        id_class_dict_file=f"{output_dir}/{output_prefix}_id_class_dict.pkl",
#        test_data_file=f"{output_dir}/{output_prefix}_labeled_test.dataset",
#        output_directory=output_dir,
#        output_prefix=output_prefix,
#    )
#
#
## In[3]:
#
#
#cc.plot_conf_mat(
#        conf_mat_dict={"Geneformer": all_metrics_test["conf_matrix"]},
#        output_directory=output_dir,
#        output_prefix=output_prefix,
#        custom_class_order=["nf","hcm","dcm"],
#)
#
#
## In[4]:
#
#
#cc.plot_predictions(
#    predictions_file=f"{output_dir}/{output_prefix}_pred_dict.pkl",
#    id_class_dict_file=f"{output_dir}/{output_prefix}_id_class_dict.pkl",
#    title="disease",
#    output_directory=output_dir,
#    output_prefix=output_prefix,
#    custom_class_order=["nf","hcm","dcm"],
#)
#
#
## In[5]:
#
#
#all_metrics_test
#
##
#/media/volume/boot-vol-vince_12apr/vjcjul10bout_darm
#├── 240710_geneformer_cellClassifier_darmanis_test
#│   ├── darmanis_test_eval_metrics_dict.pkl
#│   └── ksplit1
#│       ├── checkpoint-26
#│       │   ├── config.json
#│       │   ├── optimizer.pt
#│       │   ├── pytorch_model.bin
#│       │   ├── rng_state.pth
#│       │   ├── scheduler.pt
#│       │   ├── trainer_state.json
#│       │   └── training_args.bin
#│       ├── config.json
#│       ├── darmanis_test_pred_dict.pkl
#│       ├── pytorch_model.bin
#│       └── training_args.bin
#├── darmanis_test_id_class_dict.pkl
#├── darmanis_test_labeled_test.dataset
#│   ├── data-00000-of-00001.arrow
#│   ├── dataset_info.json
#│   └── state.json
#└── darmanis_test_labeled_train.dataset
#    ├── cache-09caec543f147a12.arrow
#    ├── cache-37561df3874ca2c7.arrow
#    ├── cache-3f56e957501eb5be_00000_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00001_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00002_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00003_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00004_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00005_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00006_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00007_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00008_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00009_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00010_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00011_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00012_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00013_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00014_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00015_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00016_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00017_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00018_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00019_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00020_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00021_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00022_of_00024.arrow
#    ├── cache-3f56e957501eb5be_00023_of_00024.arrow
#    ├── cache-45e63246554b8900_00000_of_00024.arrow
#    ├── cache-45e63246554b8900_00001_of_00024.arrow
#    ├── cache-45e63246554b8900_00002_of_00024.arrow
#    ├── cache-45e63246554b8900_00003_of_00024.arrow
#    ├── cache-45e63246554b8900_00004_of_00024.arrow
#    ├── cache-45e63246554b8900_00005_of_00024.arrow
#    ├── cache-45e63246554b8900_00006_of_00024.arrow
#    ├── cache-45e63246554b8900_00007_of_00024.arrow
#    ├── cache-45e63246554b8900_00008_of_00024.arrow
#    ├── cache-45e63246554b8900_00009_of_00024.arrow
#    ├── cache-45e63246554b8900_00010_of_00024.arrow
#    ├── cache-45e63246554b8900_00011_of_00024.arrow
#    ├── cache-45e63246554b8900_00012_of_00024.arrow
#    ├── cache-45e63246554b8900_00013_of_00024.arrow
#    ├── cache-45e63246554b8900_00014_of_00024.arrow
#    ├── cache-45e63246554b8900_00015_of_00024.arrow
#    ├── cache-45e63246554b8900_00016_of_00024.arrow
#    ├── cache-45e63246554b8900_00017_of_00024.arrow
#    ├── cache-45e63246554b8900_00018_of_00024.arrow
#    ├── cache-45e63246554b8900_00019_of_00024.arrow
#    ├── cache-45e63246554b8900_00020_of_00024.arrow
#    ├── cache-45e63246554b8900_00021_of_00024.arrow
#    ├── cache-45e63246554b8900_00022_of_00024.arrow
#    ├── cache-45e63246554b8900_00023_of_00024.arrow
#    ├── cache-56f1898c47acfd04.arrow
#    ├── cache-60c8bbb2ee5f1674_00000_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00001_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00002_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00003_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00004_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00005_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00006_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00007_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00008_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00009_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00010_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00011_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00012_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00013_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00014_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00015_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00016_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00017_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00018_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00019_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00020_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00021_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00022_of_00024.arrow
#    ├── cache-60c8bbb2ee5f1674_00023_of_00024.arrow
#    ├── cache-6cd7ee1b36475ee6.arrow
#    ├── cache-6eb0be440fd89395_00000_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00001_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00002_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00003_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00004_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00005_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00006_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00007_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00008_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00009_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00010_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00011_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00012_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00013_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00014_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00015_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00016_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00017_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00018_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00019_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00020_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00021_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00022_of_00024.arrow
#    ├── cache-6eb0be440fd89395_00023_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00000_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00001_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00002_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00003_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00004_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00005_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00006_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00007_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00008_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00009_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00010_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00011_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00012_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00013_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00014_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00015_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00016_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00017_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00018_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00019_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00020_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00021_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00022_of_00024.arrow
#    ├── cache-c3e9fec69efdc0a9_00023_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00000_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00001_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00002_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00003_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00004_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00005_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00006_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00007_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00008_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00009_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00010_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00011_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00012_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00013_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00014_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00015_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00016_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00017_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00018_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00019_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00020_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00021_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00022_of_00024.arrow
#    ├── cache-eabb17fc1df05b60_00023_of_00024.arrow
#    ├── data-00000-of-00001.arrow
#    ├── dataset_info.json
#    └── state.json
#
#5 directories, 167 files
#%VC_JetS> 
#
#
