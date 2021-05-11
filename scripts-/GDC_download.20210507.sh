#! /bin/sh


project=$1


### get all the case/sample IDs
curl "https://api.gdc.cancer.gov/v0/all?query=$project&size=165" > $project.samples.json


### RIP from json file
cat $project.samples.json | tr '\054' '\012' | egrep "submitter_id" |  egrep "\"}$" | egrep -v "txt|tsv|maf" | sed 's/"submitter_id"://g' | sed 's/}/,#/g' | tr -d '\012' | sed 's/,#$//g' | tr '\043' '\012' > $project.samples.lst


cat /home/cdavies/resource/Payload.header $project.samples.lst /home/cdavies/resource/Payload.footer > Payload.samples.general

################## CNV
cat Payload.samples.general | perl -pe 's/swap_me_out/Copy Number Segment/g' > Payload.samples.cnv

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.cnv 'https://api.gdc.cancer.gov/files' > ALL.$project.cnv.tsv

#cat ALL.$project.cnv.tsv | cut -f5,14,15 | tail -n +2 >  ALL.$project.cnv.to_fetch.tsv
cat ALL.$project.cnv.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.cnv.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.cnv.to_fetch.tsv
mv gdc_download_* data_cnv.tar.gz


##################### METHYLATION
cat Payload.samples.general | perl -pe 's/swap_me_out/Methylation Beta Value/g' > Payload.samples.methylation

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.methylation 'https://api.gdc.cancer.gov/files' > ALL.$project.methylation.tsv

cat ALL.$project.cnv.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.methylation.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.methylation.to_fetch.tsv
mv gdc_download_* data_methylation.tar.gz


##################### TRANSCRIPTION PROFILE
cat Payload.samples.general | perl -pe 's/swap_me_out/Gene Expression Quantification/g' > Payload.samples.Tx_profile

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.Tx_profile 'https://api.gdc.cancer.gov/files' > ALL.$project.Tx_profile.tsv

cat ALL.$project.Tx_profile.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.Tx_profile.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.Tx_profile.to_fetch.tsv --searchstring htseq
mv gdc_download_* data_Tx_profile.tar.gz


#####################  MAF calls
cat Payload.samples.general | perl -pe 's/swap_me_out/Masked Somatic Mutation/g' > Payload.samples.maf

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.maf 'https://api.gdc.cancer.gov/files' > ALL.$project.maf.tsv

cat ALL.$project.maf.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.maf.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.maf.to_fetch.tsv
mv gdc_download_* data_maf.tar.gz


#####################  BIOSPECIMEN
cat Payload.samples.general | perl -pe 's/swap_me_out/Biospecimen Supplement/g' > Payload.samples.biospecimen

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.biospecimen 'https://api.gdc.cancer.gov/files' > ALL.$project.biospecimen.tsv

cat ALL.$project.biospecimen.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.biospecimen.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.biospecimen.to_fetch.tsv
mv gdc_download_* data_biospecimen.tar.gz


#####################  CLINICAL
cat Payload.samples.general | perl -pe 's/swap_me_out/Clinical Supplement/g' > Payload.samples.clinical

echo "sleep 5 before payload request"
sleep 5
curl --request POST --header "Content-Type: application/json" --data @Payload.samples.clinical 'https://api.gdc.cancer.gov/files' > ALL.$project.clinical.tsv

cat ALL.$project.clinical.tsv | ~/bin/scripts-python/find_field_headers.py -c -n cases.0.samples.0.portions.0.analytes.0.aliquots.0.submitter_id,file_id,file_name | tail -n +2 >  ALL.$project.clinical.to_fetch.tsv

echo "sleep 5 before batch data request"
sleep 5
echo "fetching data"
~/bin/scripts-python/GDC_grab3.py -f ALL.$project.clinical.to_fetch.tsv
mv gdc_download_* data_clinical.tar.gz

