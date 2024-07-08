

library(SingleCellExperiment)
load("darpok.rda")
eid = make.names(rowData(darpok)$ens, unique=TRUE)
rownames(darpok) = eid
names(rowData(darpok)) = "ensembl_id"
dd = scRNAseq::DarmanisBrainData()
cc = colSums(assay(dd))
darpok$n_counts = as.numeric(cc)
dir.create("vjcfulldarm")
library(zellkonverter)
#writeH5AD(darpok, "vjcfulldarm/darpok.h5ad")
dd
darpok
darpok$age = dd$age
names(colData(dd))
darpok$cell.type = dd$cell.type
table(dd$tissue)
darpok$tissue  = dd$tissue
darpok
table(darpok$c1.chip.id)
table(dd$c1.chip.id)
darpok$chipid = dd$c1.chip.id
darpok
