# BiocGF
interface to geneformer

This R package include a complete snapshot of Geneformer from 
```
https://huggingface.co/ctheodoris/Geneformer
```
Specifically we have not attempted to work with code
changes after commit  fb130e.   We are grateful to the developers
and authors of this system for their transparency in offering these resources
underlying the Nature paper PMID 37258680, [PMC link](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10949956/).

These R interfaces are very preliminary.  At present code in vignette just demonstrates aspects
of tokenization.  The heart-failure example notebook code is mostly
transcribed into
a function `setup_and_run_Classifier`.  At present, confusion data on this example looks like

```
$conf_matrix
     dcm    nf  hcm
dcm  347     4  268
nf     7 11185  152
hcm 2162    65 7588

$macro_f1
$macro_f1[[1]]
[1] 0.6875888


$acc
[1] 0.8779502
```

See the folder inst/python/scripts for R scripts that run the heart failure
example, fine6.R is latest incarnation.  This will use about 20GB CPU RAM and
generate 2.2 GB of output.

Thanks to NSF ACCESS allocation BIR190004 for access to GPU and storage.
