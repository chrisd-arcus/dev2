#! /bin/sh
### $1 is the project name. (Same name as the directory the data resies in)

### processes A downloaded GDC data directory, and unpacks the tar files for each data type.
### run from the directory that *contains* the project download directories (e.g CGCI-BLGSP, MMRF-COMMPASS etc)


### For just one project:
for j in $(ls -d $1); do
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
	rm ../$base.data.dir/*star*    ### gets rid of STAR data in transcriptome profiling
	rm -r *
	cd ..
	rm -r $base.dir
	mv data.*.data.dir $j.unpacked
	cp *.to_fetch.tsv $j.unpacked
    done
    cd ..
done
