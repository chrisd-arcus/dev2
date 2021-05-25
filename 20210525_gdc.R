library(readr)
library(dplyr) ## allows piping
library(tidyr)

# Functions ---------------------------------------------------------------

tmp_replace <- function(x){
  #'Finds the '-- string and replaces with NA
  #' @param x (str) String to replace.
  return(ifelse(x %in% c("'--", 'N/A','[Unknown]','[Not Available]','[Not Applicable]','[Not Evaluated]'), NA, x))
}

gdc_collapser <- function(s){
  #' Removes NA and Unknown and joins them with a "," delimiter.
  #' @param s (str) String to filter and join.
  unique_s <- sort(unique(s[!is.na(s)]))
  unique_s <- unique_s[unique_s != 'Unknown']
  res <- paste(unique_s, collapse=',')
  return(res)
}

# used to map stage
mapper_stage <- c('I' = 1, 'II' = 2, 'III' = 3, 'IV' = 4)


# Start -------------------------------------------------------------------

## processing GDC heme datasets

harmony <- Sys.glob('~/Downloads/incoming/harmony/*/*txt')


## BEAT AML :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

beat_aml_raw <- read_tsv(harmony[[1]], skip = 1)
beat_aml_tmp <- beat_aml_raw %>%
  mutate(CASE = paste('BEATAML-', CASE, sep='')) %>%
  mutate_at(vars(GENDER, RACE, ETHNICITY, VITAL_STATUS), tolower) %>%
  mutate_all(tmp_replace)

View(beat_aml_tmp)
beat_aml <- beat_aml_tmp


## CGCI BLGSP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

cgci_blgsp_raw <- read_tsv(harmony[[2]], skip = 1)

cgci_blgsp_tmp <- cgci_blgsp_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS),
         CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE)) %>%
  mutate(CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE]) 

## collapse treatment to each CASE ID
cgci_blgsp_tx <- cgci_blgsp_tmp %>%
  dplyr::select(CASE, MEASURE_OF_RESPONSE, THERAPEUTIC_AGENTS) %>%
  ## here we collapse the columns based on CASE ID
  group_by(CASE) %>%
  summarise(MEASURE_OF_RESPONSE = gdc_collapser(MEASURE_OF_RESPONSE),
            THERAPEUTIC_AGENTS = gdc_collapser(THERAPEUTIC_AGENTS))

## generate final data.frame
cgci_blgsp <- cgci_blgsp_tmp %>%
  dplyr::select(-MEASURE_OF_RESPONSE, -THERAPEUTIC_AGENTS) %>% ## keep all other columns except the two columns
  distinct() %>% ## create distinct cases and join with above
  left_join(cgci_blgsp_tx)

View(cgci_blgsp)

## CTSP DLBCL1 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ctsp_dlbcl1_raw <- read_tsv(harmony[[3]], skip = 1)
ctsp_dlbcl1_tmp <- ctsp_dlbcl1_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
    VITAL_STATUS = tolower(VITAL_STATUS),
    CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE),
    CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE])

View(ctsp_dlbcl1_tmp)
ctsp_dlbcl1 <- ctsp_dlbcl1_tmp

## MMRF COMMPASS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

mmrf_commpass_raw <- read_tsv(harmony[[4]], skip = 1)
mmrf_commpass_tmp <- mmrf_commpass_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS),
         CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE),
         CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE])

## collapse treatment to each CASE ID
mmrf_commpass_tx <- mmrf_commpass_tmp %>%
    dplyr::select(CASE, THERAPEUTIC_AGENTS) %>%
    ## here we collapse the columns based on CASE ID
    group_by(CASE) %>%
    summarise(THERAPEUTIC_AGENTS = gdc_collapser(THERAPEUTIC_AGENTS))

   ## generate final data.frame
mmrf_commpass <- mmrf_commpass_tmp %>%
    dplyr::select(-THERAPEUTIC_AGENTS) %>% ## keep all other columns except the ONE column
    distinct() %>% ## create distinct cases and join with above
    left_join(mmrf_commpass_tx)

View(mmrf_commpass)
   
## NCICCR DLBCL :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

nciccr_dlbcl_raw <- read_tsv(harmony[[5]], skip = 1)
nciccr_dlbcl_tmp <- nciccr_dlbcl_raw %>%
     mutate_all(tmp_replace) %>%
     mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
            VITAL_STATUS = tolower(VITAL_STATUS),
            CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE),
            CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE],
            DEATH_DAYS_TO = ifelse(VITAL_STATUS == "dead",LAST_CONTACT_DAYS_TO,DEATH_DAYS_TO))
   
View(nciccr_dlbcl_tmp)
nciccr_dlbcl <- nciccr_dlbcl_tmp

## OHSU CNL :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ohsu_cnl_raw <- read_tsv(harmony[[6]], skip = 1)
ohsu_cnl_tmp <- ohsu_cnl_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(CASE = paste('OHSU-CNL-', CASE, sep='')) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS),
         CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE),
         CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE],
         DEATH_DAYS_TO = ifelse(VITAL_STATUS == "dead",LAST_CONTACT_DAYS_TO,DEATH_DAYS_TO))

View(ohsu_cnl_tmp)
ohsu_cnl <- ohsu_cnl_tmp

## TARGET-ALL-P1 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

target_all_1_raw <- read_tsv(harmony[[7]], skip = 1)
target_all_1_tmp <- target_all_1_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS))

View(target_all_1_tmp)
target_all_1 <- target_all_1_tmp

## TARGET-ALL-P2 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

target_all_2_raw <- read_tsv(harmony[[8]], skip = 1)
target_all_2_tmp <- target_all_2_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS))

View(target_all_2_tmp)
target_all_2 <- target_all_2_tmp

## TARGET-ALL-P3 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

target_all_3_raw <- read_tsv(harmony[[9]], skip = 1)
target_all_3_tmp <- target_all_3_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS))

View(target_all_3_tmp)
target_all_3 <- target_all_3_tmp

## TARGET-AML ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

target_aml_raw <- read_tsv(harmony[[10]], skip = 1)
target_aml_tmp <- target_aml_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO)), ## fix days to birth
         VITAL_STATUS = tolower(VITAL_STATUS))

View(target_aml_tmp)
target_aml <- target_aml_tmp

## TCGA-DLBC ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

tcga_dlbc_raw <- read_tsv(harmony[[11]], skip = 1)
tcga_dlbc_tmp <- tcga_dlbc_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO))) %>% ## fix days to birth
  mutate_at(vars(GENDER, RACE, ETHNICITY, VITAL_STATUS), tolower)%>%
  mutate(CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE)) %>%
  mutate(CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE])

View(tcga_dlbc_tmp)
tcga_dlbc <- tcga_dlbc_tmp

## TCGA-LAML ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

tcga_laml_raw <- read_tsv(harmony[[12]], skip = 1)
tcga_laml_tmp <- tcga_laml_raw %>%
  mutate_all(tmp_replace) %>%
  mutate(BIRTH_DAYS_TO = abs(as.numeric(BIRTH_DAYS_TO))) %>% ## fix days to birth
  mutate_at(vars(GENDER, RACE, ETHNICITY, VITAL_STATUS), tolower)%>%
  mutate(CLINICAL_STAGE = gsub('Stage ', '', CLINICAL_STAGE)) %>%
  mutate(CLINICAL_STAGE = mapper_stage[CLINICAL_STAGE])

View(tcga_laml_tmp)
tcga_laml <- tcga_laml_tmp
