# BiocGF
interface to geneformer

very preliminary.  at present code in vignette just demonstrates aspects
of tokenization.  the heart-failure example notebook code is mostly
transcribed.  at present, confusion data on this example looks like

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
