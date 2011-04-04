# $Id$
# ======================================================================
#
# Test sample SOAP::Lite clients run.
#
# ======================================================================

#PERL = perl
PERL = /ebi/extserv/bin/perl/bin/perl
#PERL = /sw/arch/bin/perl
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Run all test sets
# TODO: clustalo dbfetch prank mview
all: ebeye \
clustalw2 dbclustal kalign mafft muscle tcoffee \
emboss_matcher emboss_needle emboss_stretcher emboss_water lalign \
iprscan \
clustalw2_phylogeny \
fasta fastm ncbiblast psiblast psisearch wublast

clean: ebeye_clean \
clustalw2_clean dbclustal_clean kalign_clean mafft_clean muscle_clean tcoffee_clean \
emboss_matcher_clean emboss_needle_clean emboss_stretcher_clean emboss_water_clean lalign_clean \
iprscan_clean \
clustalw2_phylogeny_clean \
fasta_clean fastm_clean ncbiblast_clean psiblast_clean psisearch_clean wublast_clean

# ClustalW 2.0.x
clustalw2: clustalw2_params clustalw2_param_detail clustalw2_align clustalw2_align_stdin_stdout

clustalw2_params:
	${PERL} clustalw2_soaplite.pl --params

clustalw2_param_detail:
	${PERL} clustalw2_soaplite.pl --paramDetail alignment

clustalw2_align:
	${PERL} clustalw2_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.tfa

clustalw2_align_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} clustalw2_soaplite.pl --email ${EMAIL} --quiet --outformat aln-clustalw --outfile - - > clustalw2-blah.aln

clustalw2_clean:
	rm -f clustalw2-*

# ClustalW 2.0.x Phylogeny
clustalw2_phylogeny: clustalw2_phylogeny_params clustalw2_phylogeny_param_detail clustalw2_phylogeny_file clustalw2_phylogeny_stdin

clustalw2_phylogeny_params:
	${PERL} clustalw2_phylogeny_soaplite.pl --params

clustalw2_phylogeny_param_detail:
	${PERL} clustalw2_phylogeny_soaplite.pl --paramDetail tree

clustalw2_phylogeny_file:
	${PERL} clustalw2_phylogeny_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.aln

clustalw2_phylogeny_stdin_stdout:
	cat ../test_data/multi_prot.aln | ${PERL} clustalw2_phylogeny_soaplite.pl --email ${EMAIL} --quiet --outfile - - > clustalw2_phylogeny-blah.ph

clustalw2_phylogeny_clean:
	rm -f clustalw2_phylogeny-*

# DbClustal
dbclustal: dbclustal_params dbclustal_param_detail
# TODO: dbclustal_file

dbclustal_params:
	${PERL} dbclustal_soaplite.pl --params

dbclustal_param_detail:
	${PERL} dbclustal_soaplite.pl --paramDetail outformat

dbclustal_file:
	${PERL} dbclustal_soaplite.pl --email ${EMAIL} ???

dbclustal_clean:
	rm -f dbclustal-*

# EB-eye
ebeye: ebeye_listDomains ebeye_getNumberOfResults ebeye_getResultsIds ebeye_getAllResultsIds ebeye_listFields ebeye_getResults ebeye_getEntry \
ebeye_getEntries ebeye_getEntryFieldUrls ebeye_getEntriesFieldUrls ebeye_getDomainsReferencedInDomain ebeye_getDomainsReferencedInEntry \
ebeye_listAdditionalReferenceFields ebeye_getReferencedEntries ebeye_getReferencedEntriesSet ebeye_getReferencedEntriesFlatSet \
ebeye_getDomainsHierarchy ebeye_getDetailledNumberOfResults ebeye_listFieldsInformation

ebeye_listDomains:
	${PERL} ebeye_soaplite.pl --listDomains

ebeye_getNumberOfResults:
	${PERL} ebeye_soaplite.pl --getNumberOfResults uniprot 'azurin'

ebeye_getResultsIds:
	${PERL} ebeye_soaplite.pl --getResultsIds uniprot 'azurin' 1 10

ebeye_getAllResultsIds:
	${PERL} ebeye_soaplite.pl --getAllResultsIds uniprot 'azurin'

ebeye_listFields:
	${PERL} ebeye_soaplite.pl --listFields uniprot

ebeye_getResults:
	${PERL} ebeye_soaplite.pl --getResults uniprot 'azurin' 'id,acc,name,status' 1 10

ebeye_getEntry:
	${PERL} ebeye_soaplite.pl --getEntry uniprot 'WAP_RAT' 'id,acc,name,status'

ebeye_getEntries:
	${PERL} ebeye_soaplite.pl --getEntries uniprot 'WAP_RAT,WAP_MOUSE' 'id,acc,name,status'

ebeye_getEntryFieldUrls:
	${PERL} ebeye_soaplite.pl --getEntryFieldUrls uniprot 'WAP_RAT' 'id'

ebeye_getEntriesFieldUrls:
	${PERL} ebeye_soaplite.pl --getEntriesFieldUrls uniprot 'WAP_RAT,WAP_MOUSE' 'id'

ebeye_getDomainsReferencedInDomain:
	${PERL} ebeye_soaplite.pl --getDomainsReferencedInDomain uniprot

ebeye_getDomainsReferencedInEntry:
	${PERL} ebeye_soaplite.pl --getDomainsReferencedInEntry uniprot 'WAP_RAT'

ebeye_listAdditionalReferenceFields:
	${PERL} ebeye_soaplite.pl --listAdditionalReferenceFields uniprot

ebeye_getReferencedEntries:
	${PERL} ebeye_soaplite.pl --getReferencedEntries uniprot 'WAP_RAT' interpro

ebeye_getReferencedEntriesSet:
	${PERL} ebeye_soaplite.pl --getReferencedEntriesSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getReferencedEntriesFlatSet:
	${PERL} ebeye_soaplite.pl --getReferencedEntriesFlatSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getDomainsHierarchy:
	${PERL} ebeye_soaplite.pl --getDomainsHierarchy

ebeye_getDetailledNumberOfResults: ebeye_getDetailledNumberOfResults_flat ebeye_getDetailledNumberOfResults_tree

ebeye_getDetailledNumberOfResults_flat:
	${PERL} ebeye_soaplite.pl --getDetailledNumberOfResults allebi 'azurin' true

ebeye_getDetailledNumberOfResults_tree:
	${PERL} ebeye_soaplite.pl --getDetailledNumberOfResults allebi 'azurin' false

ebeye_listFieldsInformation:
	${PERL} ebeye_soaplite.pl --listFieldsInformation uniprot

ebeye_clean:

# EMBOSS matcher
emboss_matcher: emboss_matcher_param_detail emboss_matcher_dbid
# TODO: emboss_matcher_params emboss_matcher_file

emboss_matcher_params:
	${PERL} emboss_matcher_soaplite.pl --params

emboss_matcher_param_detail:
	${PERL} emboss_matcher_soaplite.pl --paramDetail matrix

emboss_matcher_dbid:
	${PERL} emboss_matcher_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_matcher_clean:
	rm -f emboss_matcher-*

# EMBOSS needle
emboss_needle: emboss_needle_param_detail emboss_needle_dbid
# TODO: emboss_needle_params emboss_needle_file

emboss_needle_params:
	${PERL} emboss_needle_soaplite.pl --params

emboss_needle_param_detail:
	${PERL} emboss_needle_soaplite.pl --paramDetail matrix

emboss_needle_dbid:
	${PERL} emboss_needle_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_needle_clean:
	rm -f emboss_needle-*

# EMBOSS stretcher
emboss_stretcher: emboss_stretcher_param_detail emboss_stretcher_dbid
# TODO: emboss_stretcher_params emboss_stretcher_file

emboss_stretcher_params:
	${PERL} emboss_stretcher_soaplite.pl --params

emboss_stretcher_param_detail:
	${PERL} emboss_stretcher_soaplite.pl --paramDetail matrix

emboss_stretcher_dbid:
	${PERL} emboss_stretcher_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_stretcher_clean:
	rm -f emboss_stretcher-*

# EMBOSS water
emboss_water: emboss_water_param_detail emboss_water_dbid
# TODO: emboss_water_params emboss_water_file

emboss_water_params:
	${PERL} emboss_water_soaplite.pl --params

emboss_water_param_detail:
	${PERL} emboss_water_soaplite.pl --paramDetail matrix

emboss_water_dbid:
	${PERL} emboss_water_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_water_clean:
	rm -f emboss_water-*

# FASTA
fasta: fasta_params fasta_param_detail fasta_file fasta_dbid fasta_stdin_stdout

fasta_params:
	${PERL} fasta_soaplite.pl --params

fasta_param_detail:
	${PERL} fasta_soaplite.pl --paramDetail program

fasta_file:
	${PERL} fasta_soaplite.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

fasta_dbid:
	${PERL} fasta_soaplite.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

fasta_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} fasta_soaplite.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > fasta-blah.txt

fasta_clean:
	rm -f fasta-*

# FASTM
fastm: fastm_params fastm_param_detail fastm_file fastm_stdin_stdout

fastm_params:
	${PERL} fastm_soaplite.pl --params

fastm_param_detail:
	${PERL} fastm_soaplite.pl --paramDetail program

fastm_file:
	${PERL} fastm_soaplite.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein ../test_data/peptides.fasta

fastm_stdin_stdout:
	cat ../test_data/peptides.fasta | ${PERL} fastm_soaplite.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > fastm-blah.txt

fastm_clean:
	rm -f fastm-*

# InterProScan
iprscan: iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_multifasta_file
# TODO: iprscan_params 

iprscan_params:
	${PERL} iprscan_soaplite.pl --params

iprscan_param_detail:
	${PERL} iprscan_soaplite.pl --paramDetail appl

iprscan_file:
	${PERL} iprscan_soaplite.pl --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${PERL} iprscan_soaplite.pl --email ${EMAIL} UNIPROT:ABCC9_HUMAN

iprscan_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} iprscan_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > iprscan-blah.txt

iprscan_id_list_file:
	${PERL} iprscan_soaplite.pl --email ${EMAIL} --outformat out --outfile - @../test_data/uniprot_id_list.txt

iprscan_multifasta_file:
	${PERL} iprscan_soaplite.pl --email ${EMAIL} --outformat out --outfile - --multifasta  ../test_data/multi_prot.tfa

iprscan_clean:
	rm -f iprscan-*

# Kalign
kalign: kalign_params kalign_param_detail kalign_file kalign_stdin_stdout

kalign_params:
	${PERL} kalign_soaplite.pl --params

kalign_param_detail:
	${PERL} kalign_soaplite.pl --paramDetail format

kalign_file:
	${PERL} kalign_soaplite.pl --email ${EMAIL} --stype protein ../test_data/multi_prot.tfa

kalign_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} kalign_soaplite.pl --email ${EMAIL} --stype protein --quiet --outformat aln-clustalw --outfile - - > kalign-blah.aln

kalign_clean:
	rm -f kalign-*

# lalign
lalign: lalign_param_detail lalign_dbid
# TODO: lalign_params lalign_file

lalign_params:
	${PERL} lalign_soaplite.pl --params

lalign_param_detail:
	${PERL} lalign_soaplite.pl --paramDetail matrix

lalign_dbid:
	${PERL} lalign_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

lalign_clean:
	rm -f lalign-*

# MAFFT
mafft: mafft_params mafft_param_detail mafft_file mafft_stdin_stdout

mafft_params:
	${PERL} mafft_soaplite.pl --params

mafft_param_detail:
	${PERL} mafft_soaplite.pl --paramDetail matrix

mafft_file:
	${PERL} mafft_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.tfa

mafft_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} mafft_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > mafft-blah.aln

mafft_clean:
	rm -f mafft-*

# MUSCLE
muscle: muscle_params muscle_param_detail muscle_file muscle_stdin_stdout

muscle_params:
	${PERL} muscle_soaplite.pl --params

muscle_param_detail:
	${PERL} muscle_soaplite.pl --paramDetail format

muscle_file:
	${PERL} muscle_soaplite.pl --email ${EMAIL} --output clw ../test_data/multi_prot.tfa

muscle_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} muscle_soaplite.pl --email ${EMAIL} --output clw --quiet --outformat out --outfile - - > muscle-blah.aln

muscle_clean:
	rm -f muscle-*

# NCBI BLAST
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout

ncbiblast_params:
	${PERL} ncbiblast_soaplite.pl --params

ncbiblast_param_detail:
	${PERL} ncbiblast_soaplite.pl --paramDetail program

ncbiblast_file:
	${PERL} ncbiblast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PERL} ncbiblast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

ncbiblast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} ncbiblast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > ncbiblast-blah.txt

ncbiblast_clean:
	rm -f ncbiblast-*

# PSI-BLAST
psiblast: psiblast_file psiblast_dbid psiblast_stdin_stdout

psiblast_file:
	${PERL} psiblast_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psiblast_dbid:
	${PERL} psiblast_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 UNIPROT:ABCC9_HUMAN

psiblast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psiblast_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --quiet --outformat out --outfile - - > psiblast-blah.txt

psiblast_clean:
	rm -f psiblast-*

# PSI-Search
psisearch: psisearch_params psisearch_param_detail psisearch_file psisearch_dbid psisearch_stdin_stdout

psisearch_params:
	${PERL} psisearch_soaplite.pl --params

psisearch_param_detail:
	${PERL} psisearch_soaplite.pl --paramDetail matrix

psisearch_file:
	${PERL} psisearch_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --align 10 ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psisearch_dbid:
	${PERL} psisearch_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --align 10 UNIPROT:ABCC9_HUMAN

psisearch_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psisearch_soaplite.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --align 10 --quiet --outformat out --outfile - - > psisearch-blah.txt

psisearch_clean:
	rm -f psisearch-*

# T-Coffee
tcoffee: tcoffee_params tcoffee_param_detail tcoffee_file tcoffee_stdin_stdout

tcoffee_params:
	${PERL} tcoffee_soaplite.pl --params

tcoffee_param_detail:
	${PERL} tcoffee_soaplite.pl --paramDetail matrix

tcoffee_file:
	${PERL} tcoffee_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.tfa

tcoffee_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} tcoffee_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > tcoffee-blah.aln

tcoffee_clean:
	rm -f tcoffee-*

# WU-BLAST
wublast: wublast_params wublast_param_detail wublast_file wublast_dbid wublast_stdin_stdout

wublast_params:
	${PERL} wublast_soaplite.pl --params

wublast_param_detail:
	${PERL} wublast_soaplite.pl --paramDetail program

wublast_file:
	${PERL} wublast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

wublast_dbid:
	${PERL} wublast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

wublast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} wublast_soaplite.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > wublast-blah.txt

wublast_clean:
	rm -f wublast-*
