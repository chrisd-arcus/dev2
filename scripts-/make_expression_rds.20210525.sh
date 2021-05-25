#! /bin/sh

### $1 is the project name. run script from the directory that contains the project dir.

for i in $(ls $1/*unpacked/*Gene_Expression_Quantification.to_fetch.tsv); do

    echo $i; 
    dir1=`echo $i | cut -f1 -d'/'`; 
    dir2=`echo $i | cut -f2 -d'/'`;
    for j in $(cat $i | tr '\011' '\174' | egrep htseq); do 
	case=`echo $j | cut -f1 -d'|'`
	file=`echo $j | cut -f3 -d'|'`
        echo $dir1 $dir2 $j;
	echo $case $file
	echo -n .
	infile=`echo $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/$file`
	outfile1=`echo $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/$case.htseq.txt`
	outfile2=`echo $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/$case.htseq.pasteable.txt`
	ls -l $infile
	echo $outfile1   $outfile2
	echo "ENS_transcript|"$case | tr '\174' '\011' > $outfile1
	echo $case > $outfile2
	zcat $infile | sort  >> $outfile1
	zcat $infile | sort | cut -f2 >> $outfile2
    done;
    cat $outfile1 | cut -f1 | sed 's/ENS_transcript/ENS_gene/g' > $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/aaa_pasteable_genelist.txt
    paste $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/aaa_pasteable_genelist.txt $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/*htseq.pasteable* > $dir1/$dir2/data.Gene_Expression_Quantification.data.dir/$dir1.htseq.all.tsv

done
