#! /bin/sh

### processes the downloaded GDC data directories, and unpacks the tar files for each data type.
### run from the directory that contains the project download directories (e.g CGCI-BLGSP, MMRF-COMMPASS etc)

for j in $(ls -d *); do 
    cd $j 
    mkdir $j.unpacked

    for i in $(ls data.*.tar.gz); do 
	base=`echo $i | cut -f1,2 -d '.'`
	mkdir $base.dir
	cp $i $base.dir
	cd $base.dir
	gunzip $base.tar.gz
	tar -xvf $base.tar
	mkdir ../$base.data.dir
	mv MANIFEST.txt ../$base.data.dir
	mv */* ../$base.data.dir
	rm ../$base.data.dir/*xml      ### gets rid of xml files from biosamples and clinical 
	rm ../$base.data.dir/*FPKM*    ### gets rid of FPKM counts in transcriptome profiling
	rm -r *
	cd ..
	rm -r $base.dir
	mv data.*.data.dir $j.unpacked
	cp *.to_fetch.tsv $j.unpacked
    done
    cd ..
done
