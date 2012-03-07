# $Id$
# ======================================================================
#
# Test sample SOAP::Lite clients run.
#
# ======================================================================

PERL = perl
#PERL = /ebi/extserv/bin/perl/bin/perl
#PERL = /ebi/extserv/bin/perl-5.10.1/bin/perl
#PERL = /sw/arch/bin/perl
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Prevent termination on error calling --params with SOAP::Lite > 0.60a
JDispatcher_params_suffix=|| true

# Run all test sets
all: \
dbfetch \
ebeye \
msa \
pfa \
phylogeny \
psa \
sfc \
so \
sss \
st

clean: \
dbfetch_clean \
ebeye_clean \
msa_clean \
pfa_clean \
phylogeny_clean \
psa_clean \
sfc_clean \
so_clean \
sss_clean \
st_clean

# Multiple Sequence Alignment (MSA)
msa: \
clustalo \
clustalw2 \
dbclustal \
kalign \
mafft \
muscle \
mview \
prank \
tcoffee

msa_clean: \
clustalo_clean \
clustalw2_clean \
dbclustal_clean \
kalign_clean \
mafft_clean \
muscle_clean \
mview_clean \
prank_clean \
tcoffee_clean

# Protein Function Analysis (PFA)
pfa: \
iprscan \
phobius

pfa_clean: \
iprscan_clean \
phobius_clean

# Phylogeny
phylogeny: \
clustalw2phylogeny

phylogeny_clean: \
clustalw2phylogeny_clean

# Pairwise Sequence Alignment (PSA)
psa: \
emboss_matcher \
emboss_needle \
emboss_stretcher \
emboss_water \
lalign

psa_clean: \
emboss_matcher_clean \
emboss_needle_clean \
emboss_stretcher_clean \
emboss_water_clean \
lalign_clean

# TODO: Sequence Format Conversion (SFC)
sfc: \
emboss_seqret \
readseq

sfc_clean: \
emboss_seqret_clean \
readseq_clean

# TODO: Sequence Operations (SO)
so: \
seqcksum

so_clean: \
seqcksum_clean

# Sequence Similarity Search (SSS)
sss: \
fasta \
fastm \
ncbiblast \
psiblast \
psisearch \
wublast

sss_clean: \
fasta_clean \
fastm_clean \
ncbiblast_clean \
psiblast_clean \
psisearch_clean \
wublast_clean

# Sequence Translation (ST)
st: \
emboss_backtranambig \
emboss_backtranseq \
emboss_sixpack \
emboss_transeq

st_clean: \
emboss_backtranambig_clean \
emboss_backtranseq_clean \
emboss_sixpack_clean \
emboss_transeq_clean

# Clustal Omega
clustalo: clustalo_params clustalo_param_detail clustalo_align clustalo_align_stdin_stdout

clustalo_params:
	${PERL} clustalo_soaplite.pl --params ${JDispatcher_params_suffix}

clustalo_param_detail:
	${PERL} clustalo_soaplite.pl --paramDetail outfmt

clustalo_align:
	${PERL} clustalo_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.tfa

clustalo_align_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} clustalo_soaplite.pl --email ${EMAIL} --quiet --outformat aln-clustal --outfile - - > clustalo-blah.aln

clustalo_clean:
	rm -f clustalo-*

# ClustalW 2.x
clustalw2: clustalw2_params clustalw2_param_detail clustalw2_align clustalw2_align_stdin_stdout

clustalw2_params:
	${PERL} clustalw2_soaplite.pl --params ${JDispatcher_params_suffix}

clustalw2_param_detail:
	${PERL} clustalw2_soaplite.pl --paramDetail alignment

clustalw2_align:
	${PERL} clustalw2_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.tfa

clustalw2_align_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} clustalw2_soaplite.pl --email ${EMAIL} --quiet --outformat aln-clustalw --outfile - - > clustalw2-blah.aln

clustalw2_clean:
	rm -f clustalw2-*

# ClustalW 2.x Phylogeny
clustalw2phylogeny: clustalw2phylogeny_params clustalw2phylogeny_param_detail clustalw2phylogeny_file clustalw2phylogeny_stdin_stdout

clustalw2phylogeny_params:
	${PERL} clustalw2phylogeny_soaplite.pl --params ${JDispatcher_params_suffix}

clustalw2phylogeny_param_detail:
	${PERL} clustalw2phylogeny_soaplite.pl --paramDetail tree

clustalw2phylogeny_file:
	${PERL} clustalw2phylogeny_soaplite.pl --email ${EMAIL} ../test_data/multi_prot.aln

clustalw2phylogeny_stdin_stdout:
	cat ../test_data/multi_prot.aln | ${PERL} clustalw2phylogeny_soaplite.pl --email ${EMAIL} --quiet --outfile - - > clustalw2_phylogeny-blah.ph

clustalw2phylogeny_clean:
	rm -f clustalw2_phylogeny-*

# DbClustal
dbclustal: dbclustal_params dbclustal_param_detail dbclustal_file

dbclustal_params:
	${PERL} dbclustal_soaplite.pl --params ${JDispatcher_params_suffix}

dbclustal_param_detail:
	${PERL} dbclustal_soaplite.pl --paramDetail output

dbclustal_file:
	${PERL} dbclustal_soaplite.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --blastreport ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt

dbclustal_clean:
	rm -f dbclustal-*

# WSDbfetch Document/literal SOAP
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${PERL} wsdbfetch_soaplite.pl getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${PERL} wsdbfetch_soaplite.pl getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	${PERL} wsdbfetch_soaplite.pl getSupportedStyles > dbfetch-getSupportedStyles.txt

dbfetch_getDbFormats:
	${PERL} wsdbfetch_soaplite.pl getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${PERL} wsdbfetch_soaplite.pl getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${PERL} wsdbfetch_soaplite.pl fetchData 'uniprotkb:wap_rat' > dbfetch-fetchData.txt

dbfetch_fetchData_file:
	${PERL} wsdbfetch_soaplite.pl fetchData @../test_data/uniprot_id_list.txt > dbfetch-fetchDataFile.txt

dbfetch_fetchData_stdin:
	cat ../test_data/uniprot_id_list.txt | ${PERL} wsdbfetch_soaplite.pl fetchData @- > dbfetch-fetchDataStdin.txt

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${PERL} wsdbfetch_soaplite.pl fetchBatch uniprotkb 'wap_rat,wap_mouse' > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file:
	${PERL} wsdbfetch_soaplite.pl fetchBatch uniprotkb @../test_data/uniprot_id_list_b.txt > dbfetch-fetchBatchFile.txt

dbfetch_fetchBatch_stdin:
	cat ../test_data/uniprot_id_list_b.txt | ${PERL} wsdbfetch_soaplite.pl fetchBatch uniprotkb - > dbfetch-fetchBatchStdin.txt

dbfetch_clean:
	rm -f dbfetch-*

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

# EMBOSS backtranambig
emboss_backtranambig: emboss_backtranambig_params emboss_backtranambig_param_detail emboss_backtranambig_dbid emboss_backtranambig_file emboss_backtranambig_stdin_stdout

emboss_backtranambig_params:
	${PERL} emboss_backtranambig_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_backtranambig_param_detail:
	${PERL} emboss_backtranambig_soaplite.pl --paramDetail codontable

emboss_backtranambig_dbid:
	${PERL} emboss_backtranambig_soaplite.pl --email ${EMAIL} --sequence uniprot:wap_rat

emboss_backtranambig_file:
	${PERL} emboss_backtranambig_soaplite.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_backtranambig_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} emboss_backtranambig_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_backtranambig-blah.txt

emboss_backtranambig_clean:
	rm -f emboss_backtranambig-*

# EMBOSS backtranseq
emboss_backtranseq: emboss_backtranseq_params emboss_backtranseq_param_detail emboss_backtranseq_dbid emboss_backtranseq_file emboss_backtranseq_stdin_stdout

emboss_backtranseq_params:
	${PERL} emboss_backtranseq_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_backtranseq_param_detail:
	${PERL} emboss_backtranseq_soaplite.pl --paramDetail codontable

emboss_backtranseq_dbid:
	${PERL} emboss_backtranseq_soaplite.pl --email ${EMAIL} --sequence uniprot:wap_rat

emboss_backtranseq_file:
	${PERL} emboss_backtranseq_soaplite.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_backtranseq_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} emboss_backtranseq_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_backtranseq-blah.txt

emboss_backtranseq_clean:
	rm -f emboss_backtranseq-*

# EMBOSS matcher
emboss_matcher: emboss_matcher_params emboss_matcher_param_detail emboss_matcher_dbid emboss_matcher_file

emboss_matcher_params:
	${PERL} emboss_matcher_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_matcher_param_detail:
	${PERL} emboss_matcher_soaplite.pl --paramDetail matrix

emboss_matcher_dbid:
	${PERL} emboss_matcher_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_matcher_file:
	${PERL} emboss_matcher_soaplite.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_matcher_clean:
	rm -f emboss_matcher-*

# EMBOSS needle
emboss_needle: emboss_needle_params emboss_needle_param_detail emboss_needle_dbid emboss_needle_file

emboss_needle_params:
	${PERL} emboss_needle_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_needle_param_detail:
	${PERL} emboss_needle_soaplite.pl --paramDetail matrix

emboss_needle_dbid:
	${PERL} emboss_needle_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_needle_file:
	${PERL} emboss_needle_soaplite.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_needle_clean:
	rm -f emboss_needle-*

# TODO: EMBOSS seqret
emboss_seqret:

emboss_seqret_clean:

# EMBOSS sixpack
emboss_sixpack: emboss_sixpack_params emboss_sixpack_param_detail emboss_sixpack_dbid emboss_sixpack_file emboss_sixpack_stdin_stdout

emboss_sixpack_params:
	${PERL} emboss_sixpack_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_sixpack_param_detail:
	${PERL} emboss_sixpack_soaplite.pl --paramDetail codontable

emboss_sixpack_dbid:
	${PERL} emboss_sixpack_soaplite.pl --email ${EMAIL} --sequence embl:L12345

emboss_sixpack_file:
	${PERL} emboss_sixpack_soaplite.pl --email ${EMAIL} --sequence ../test_data/EMBL_AB000204.fasta

emboss_sixpack_stdin_stdout:
	cat ../test_data/EMBL_AB000204.fasta | ${PERL} emboss_sixpack_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_sixpack-blah.txt

emboss_sixpack_clean:
	rm -f emboss_sixpack-*

# EMBOSS stretcher
emboss_stretcher: emboss_stretcher_params emboss_stretcher_param_detail emboss_stretcher_dbid emboss_stretcher_file

emboss_stretcher_params:
	${PERL} emboss_stretcher_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_stretcher_param_detail:
	${PERL} emboss_stretcher_soaplite.pl --paramDetail matrix

emboss_stretcher_dbid:
	${PERL} emboss_stretcher_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_stretcher_file:
	${PERL} emboss_stretcher_soaplite.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_stretcher_clean:
	rm -f emboss_stretcher-*

# EMBOSS transeq
emboss_transeq: emboss_transeq_params emboss_transeq_param_detail emboss_transeq_dbid emboss_transeq_file emboss_transeq_stdin_stdout

emboss_transeq_params:
	${PERL} emboss_transeq_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_transeq_param_detail:
	${PERL} emboss_transeq_soaplite.pl --paramDetail codontable

emboss_transeq_dbid:
	${PERL} emboss_transeq_soaplite.pl --email ${EMAIL} --sequence embl:L12345

emboss_transeq_file:
	${PERL} emboss_transeq_soaplite.pl --email ${EMAIL} --sequence ../test_data/EMBL_AB000204.fasta

emboss_transeq_stdin_stdout:
	cat ../test_data/EMBL_AB000204.fasta | ${PERL} emboss_transeq_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_transeq-blah.txt

emboss_transeq_clean:
	rm -f emboss_transeq-*

# EMBOSS water
emboss_water: emboss_water_params emboss_water_param_detail emboss_water_dbid emboss_water_file

emboss_water_params:
	${PERL} emboss_water_soaplite.pl --params ${JDispatcher_params_suffix}

emboss_water_param_detail:
	${PERL} emboss_water_soaplite.pl --paramDetail matrix

emboss_water_dbid:
	${PERL} emboss_water_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_water_file:
	${PERL} emboss_water_soaplite.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_water_clean:
	rm -f emboss_water-*

# FASTA
fasta: fasta_params fasta_param_detail fasta_file fasta_dbid fasta_stdin_stdout

fasta_params:
	${PERL} fasta_soaplite.pl --params ${JDispatcher_params_suffix}

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
	${PERL} fastm_soaplite.pl --params ${JDispatcher_params_suffix}

fastm_param_detail:
	${PERL} fastm_soaplite.pl --paramDetail program

fastm_file:
	${PERL} fastm_soaplite.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein ../test_data/peptides.fasta

fastm_stdin_stdout:
	cat ../test_data/peptides.fasta | ${PERL} fastm_soaplite.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > fastm-blah.txt

fastm_clean:
	rm -f fastm-*

# InterProScan
iprscan: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_multifasta_file

iprscan_params:
	${PERL} iprscan_soaplite.pl --params ${JDispatcher_params_suffix}

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

# TODO: InterProScan 5
iprscan5:

iprscan5_clean:

# Kalign
kalign: kalign_params kalign_param_detail kalign_file kalign_stdin_stdout

kalign_params:
	${PERL} kalign_soaplite.pl --params ${JDispatcher_params_suffix}

kalign_param_detail:
	${PERL} kalign_soaplite.pl --paramDetail format

kalign_file:
	${PERL} kalign_soaplite.pl --email ${EMAIL} --stype protein ../test_data/multi_prot.tfa

kalign_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} kalign_soaplite.pl --email ${EMAIL} --stype protein --quiet --outformat aln-clustalw --outfile - - > kalign-blah.aln

kalign_clean:
	rm -f kalign-*

# lalign
lalign: lalign_params lalign_param_detail lalign_dbid lalign_file

lalign_params:
	${PERL} lalign_soaplite.pl --params ${JDispatcher_params_suffix}

lalign_param_detail:
	${PERL} lalign_soaplite.pl --paramDetail matrix

lalign_dbid:
	${PERL} lalign_soaplite.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

lalign_file:
	${PERL} lalign_soaplite.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

lalign_clean:
	rm -f lalign-*

# MAFFT
mafft: mafft_params mafft_param_detail mafft_file mafft_stdin_stdout

mafft_params:
	${PERL} mafft_soaplite.pl --params ${JDispatcher_params_suffix}

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
	${PERL} muscle_soaplite.pl --params ${JDispatcher_params_suffix}

muscle_param_detail:
	${PERL} muscle_soaplite.pl --paramDetail format

muscle_file:
	${PERL} muscle_soaplite.pl --email ${EMAIL} --output clw ../test_data/multi_prot.tfa

muscle_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} muscle_soaplite.pl --email ${EMAIL} --output clw --quiet --outformat out --outfile - - > muscle-blah.aln

muscle_clean:
	rm -f muscle-*

# MView
mview: mview_params mview_param_detail mview_file mview_stdin_stdout

mview_params:
	${PERL} mview_soaplite.pl --params ${JDispatcher_params_suffix}

mview_param_detail:
	${PERL} mview_soaplite.pl --paramDetail outputformat

mview_file:
	${PERL} mview_soaplite.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt --alignment --ruler --consensus --htmlmarkup off

mview_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt | ${PERL} mview_soaplite.pl --email ${EMAIL} --alignment --ruler --consensus --htmlmarkup off --quiet --outformat out --outfile - - > mview-blah.aln

mview_clean:
	rm -f mview-*

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout

ncbiblast_params:
	${PERL} ncbiblast_soaplite.pl --params ${JDispatcher_params_suffix}

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

# Phobius
phobius: phobius_params phobius_param_detail phobius_file phobius_dbid phobius_stdin_stdout

phobius_params:
	${PERL} phobius_soaplite.pl --params ${JDispatcher_params_suffix}

phobius_param_detail:
	${PERL} phobius_soaplite.pl --paramDetail format

phobius_file:
	${PERL} phobius_soaplite.pl --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

phobius_dbid:
	${PERL} phobius_soaplite.pl --email ${EMAIL} UNIPROT:ABCC9_HUMAN

phobius_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} phobius_soaplite.pl --email ${EMAIL} --quiet --outformat out --outfile - - > phobius-blah.txt

phobius_clean:
	rm -f phobius-*

# PRANK
prank: prank_params prank_param_detail prank_file prank_stdin_stdout

prank_params:
	${PERL} prank_soaplite.pl --params ${JDispatcher_params_suffix}

prank_param_detail:
	${PERL} prank_soaplite.pl --paramDetail output_format

prank_file:
	${PERL} prank_soaplite.pl --email ${EMAIL} --output_format 15 ../test_data/multi_prot.tfa

prank_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} prank_soaplite.pl --email ${EMAIL} --output_format 15 --quiet --outformat aln-msf --outfile - - > prank-blah.aln

prank_clean:
	rm -f prank-*

# PSI-BLAST
psiblast: psiblast_file psiblast_dbid psiblast_stdin_stdout

psiblast_params:
	${PERL} psiblast_soaplite.pl --params ${JDispatcher_params_suffix}

psiblast_param_detail:
	${PERL} psiblast_soaplite.pl --paramDetail matrix

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
	${PERL} psisearch_soaplite.pl --params ${JDispatcher_params_suffix}

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

# TODO: Readseq
readseq:

readseq_clean:

# TODO: seqcksum
seqcksum:

seqcksum_clean:

# T-Coffee
tcoffee: tcoffee_params tcoffee_param_detail tcoffee_file tcoffee_stdin_stdout

tcoffee_params:
	${PERL} tcoffee_soaplite.pl --params ${JDispatcher_params_suffix}

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
	${PERL} wublast_soaplite.pl --params ${JDispatcher_params_suffix}

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
