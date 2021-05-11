#! /bin/sh


project=$1


### get all the case/sample IDs
curl "https://api.gdc.cancer.gov/v0/all?query=$project&size=9999" > $project.samples.json


### RIP from json file
cat $project.samples.json | tr '\054' '\012' | egrep "submitter_id" |  egrep "\"}$" | egrep -v "txt|tsv|maf" | sed 's/"submitter_id"://g' | sed 's/}/,#/g' | tr -d '\012' | sed 's/,#$//g' | tr '\043' '\012' > $project.samples.lst


cat ~/resource/Payload.header $project.samples.lst ~/resource/Payload.footer > Payload.samples.general

################################################################################################################################################


for i in $(echo "Gene_Expression_Quantification Masked_Somatic_Mutation Biospecimen_Supplement Clinical_Supplement Copy_Number_Segment Methylation_Beta_Value"); do fstring=$i; search_string=`echo $i | tr '\137' '\040'`
	echo $fstring
	echo $search_string
	echo $search_string > string.txt

	#cat Payload.samples.general | perl -pe '$swap='$search_string'; s/swap_me_out/$swap/g' > Payload.samples.$fstring
	cat ~/resource/Payload.header $project.samples.lst ~/resource/Payload.footer1 string.txt ~/resource/Payload.footer2 > Payload.samples.$fstring

	echo "sleep 5 before payload request"
	sleep 5
	curl --request POST --header "Content-Type: application/json" --data @Payload.samples.$fstring 'https://api.gdc.cancer.gov/files' > ALL.$project.$fstring.tsv

	SIZE=`cat ALL.$project.$fstring.tsv | wc -w | sed 's/^ *//g'`

	if (( SIZE > 0 )); then

		#cat ALL.$project.$fstring.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.$fstring.to_fetch.tsv
		cat ALL.$project.$fstring.tsv | tr -d '\015' | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.$fstring.to_fetch.tsv
		
		echo "sleep 5 before batch data request"
		sleep 5
		echo "fetching data"
		~/bin/scripts-python/GDC_grab3.py -f ALL.$project.$fstring.to_fetch.tsv   #  --searchstring htseq  ### only for the transcript counts
		mv gdc_download_* data.$fstring.tar.gz

		else echo "NO DATA TO DOWNLOAD"
	fi

done
