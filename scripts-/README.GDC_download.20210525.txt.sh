### /bin/sh

### $1 is the PROJECT-NAME to fetch (everything it can, data and clinical), then unpack, and make a single expression counts table.
##  CMI-ASC is a good example

mkdir $1
cd $1
### downloads the files into the current dir
~/bin/scripts-/GDC_download.20210507_3.sh $1
cd ..



### unpacks the tar.gz files, so don't mess with them first.
~/bin/scripts-/unpack_GDC_download.20210525.sh $1 




### obviously: 
~/bin/scripts-/make_expression_rds.20210525.sh $1
### (creates *.htseq.all.tsv file, for the project)



### IF necessary:
### to add a prefix to al lthe CASE(sample) names:
##  mv OHSU-CNL.htseq.all.tsv OHSU-CNL.htseq.all.tsv.bk
##  cat OHSU-CNL.htseq.all.tsv.bk | head -1 | perl -ane 'foreach $i (0..$#F){print "\tOHSU-CNL-".$F[$i]}' | sed 's/^     OHSU-CNL-//g'  > OHSU-CNL.htseq.all.tsv
##  cat OHSU-CNL.htseq.all.tsv.bk | tail -n +2 >> OHSU-CNL.htseq.all.tsv 

