# $Id$
# ======================================================================
#
# Test sample LWP clients run.
#
# ======================================================================

PERL = perl
#PERL = /ebi/extserv/bin/perl/bin/perl
#PERL = /ebi/extserv/bin/perl-5.10.1/bin/perl
#PERL = /sw/arch/bin/perl
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Run all test sets
all: \
dbfetch \
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
tcoffee \

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
iprscan5 \
phobius

pfa_clean: \
iprscan_clean \
iprscan5_clean \
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
	${PERL} clustalo_lwp.pl --params

clustalo_param_detail:
	${PERL} clustalo_lwp.pl --paramDetail outfmt

clustalo_align:
	${PERL} clustalo_lwp.pl --email ${EMAIL} ../test_data/multi_prot.tfa

clustalo_align_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} clustalo_lwp.pl --email ${EMAIL} --quiet --outformat aln-clustal --outfile - - > clustalo-blah.aln

clustalo_clean:
	rm -f clustalo-*

# ClustalW 2.x
clustalw2: clustalw2_params clustalw2_param_detail clustalw2_align clustalw2_align_stdin_stdout

clustalw2_params:
	${PERL} clustalw2_lwp.pl --params

clustalw2_param_detail:
	${PERL} clustalw2_lwp.pl --paramDetail alignment

clustalw2_align:
	${PERL} clustalw2_lwp.pl --email ${EMAIL} ../test_data/multi_prot.tfa

clustalw2_align_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} clustalw2_lwp.pl --email ${EMAIL} --quiet --outformat aln-clustalw --outfile - - > clustalw2-blah.aln

clustalw2_clean:
	rm -f clustalw2-*

# ClustalW 2.x Phylogeny
clustalw2phylogeny: clustalw2phylogeny_params clustalw2phylogeny_param_detail clustalw2phylogeny_file clustalw2phylogeny_stdin_stdout

clustalw2phylogeny_params:
	${PERL} clustalw2phylogeny_lwp.pl --params ${JDispatcher_params_suffix}

clustalw2phylogeny_param_detail:
	${PERL} clustalw2phylogeny_lwp.pl --paramDetail tree

clustalw2phylogeny_file:
	${PERL} clustalw2phylogeny_lwp.pl --email ${EMAIL} ../test_data/multi_prot.aln

clustalw2phylogeny_stdin_stdout:
	cat ../test_data/multi_prot.aln | ${PERL} clustalw2phylogeny_lwp.pl --email ${EMAIL} --quiet --outformat tree --outfile - - > clustalw2_phylogeny-blah.ph

clustalw2phylogeny_clean:
	rm -f clustalw2_phylogeny-*

# DbClustal
dbclustal: dbclustal_params dbclustal_param_detail dbclustal_file

dbclustal_params:
	${PERL} dbclustal_lwp.pl --params

dbclustal_param_detail:
	${PERL} dbclustal_lwp.pl --paramDetail output

dbclustal_file:
	${PERL} dbclustal_lwp.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --blastreport ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt

dbclustal_clean:
	rm -f dbclustal-*

# dbfetch
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${PERL} dbfetch_lwp.pl getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${PERL} dbfetch_lwp.pl getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	${PERL} dbfetch_lwp.pl getSupportedStyles > dbfetch-getSupportedStyles.txt

dbfetch_getDbFormats:
	${PERL} dbfetch_lwp.pl getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${PERL} dbfetch_lwp.pl getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${PERL} dbfetch_lwp.pl fetchData 'uniprotkb:wap_rat' > dbfetch-fetchData.txt

dbfetch_fetchData_file:
	${PERL} dbfetch_lwp.pl fetchData @../test_data/uniprot_id_list.txt fasta raw > dbfetch-fetchDataFile.txt

dbfetch_fetchData_stdin:
	cat ../test_data/uniprot_id_list.txt | ${PERL} dbfetch_lwp.pl fetchData @- fasta raw > dbfetch-fetchDataStdin.txt

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${PERL} dbfetch_lwp.pl fetchBatch uniprotkb 'wap_rat,wap_mouse' fasta raw > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file:
	${PERL} dbfetch_lwp.pl fetchBatch uniprotkb @../test_data/uniprot_id_list_b.txt fasta raw > dbfetch-fetchBatchFile.txt

dbfetch_fetchBatch_stdin:
	cat ../test_data/uniprot_id_list_b.txt | ${PERL} dbfetch_lwp.pl fetchBatch uniprotkb - fasta raw > dbfetch-fetchBatchStdin.txt

dbfetch_clean:
	rm -f dbfetch-*

# EMBOSS backtranambig
emboss_backtranambig: emboss_backtranambig_params emboss_backtranambig_param_detail emboss_backtranambig_dbid emboss_backtranambig_file emboss_backtranambig_stdin_stdout emboss_backtranambig_id_list_file emboss_backtranambig_id_list_file_stdin_stdout

emboss_backtranambig_params:
	${PERL} emboss_backtranambig_lwp.pl --params

emboss_backtranambig_param_detail:
	${PERL} emboss_backtranambig_lwp.pl --paramDetail codontable

emboss_backtranambig_dbid:
	${PERL} emboss_backtranambig_lwp.pl --email ${EMAIL} --sequence uniprot:wap_rat

emboss_backtranambig_file:
	${PERL} emboss_backtranambig_lwp.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_backtranambig_id_list_file:
	${PERL} emboss_backtranambig_lwp.pl --email ${EMAIL} --sequence @../test_data/uniprot_id_list.txt

emboss_backtranambig_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} emboss_backtranambig_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_backtranambig-blah.txt

emboss_backtranambig_id_list_file_stdin_stdout:
	cat ../test_data/uniprot_id_list.txt | ${PERL} emboss_backtranambig_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - --sequence @- > emboss_backtranambig-list.txt

emboss_backtranambig_clean:
	rm -f emboss_backtranambig-*

# EMBOSS backtranseq
emboss_backtranseq: emboss_backtranseq_params emboss_backtranseq_param_detail emboss_backtranseq_dbid emboss_backtranseq_file emboss_backtranseq_stdin_stdout emboss_backtranseq_id_list_file emboss_backtranseq_id_list_file_stdin_stdout

emboss_backtranseq_params:
	${PERL} emboss_backtranseq_lwp.pl --params

emboss_backtranseq_param_detail:
	${PERL} emboss_backtranseq_lwp.pl --paramDetail codontable

emboss_backtranseq_dbid:
	${PERL} emboss_backtranseq_lwp.pl --email ${EMAIL} --sequence uniprot:wap_rat

emboss_backtranseq_file:
	${PERL} emboss_backtranseq_lwp.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_backtranseq_id_list_file:
	${PERL} emboss_backtranseq_lwp.pl --email ${EMAIL} --sequence @../test_data/uniprot_id_list.txt

emboss_backtranseq_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} emboss_backtranseq_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_backtranseq-blah.txt

emboss_backtranseq_id_list_file_stdin_stdout:
	cat ../test_data/uniprot_id_list.txt | ${PERL} emboss_backtranseq_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - --sequence @- > emboss_backtranambig-list.txt

emboss_backtranseq_clean:
	rm -f emboss_backtranseq-*

# EMBOSS matcher
emboss_matcher: emboss_matcher_params emboss_matcher_param_detail emboss_matcher_dbid emboss_matcher_file

emboss_matcher_params:
	${PERL} emboss_matcher_lwp.pl --params

emboss_matcher_param_detail:
	${PERL} emboss_matcher_lwp.pl --paramDetail matrix

emboss_matcher_dbid:
	${PERL} emboss_matcher_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_matcher_file:
	${PERL} emboss_matcher_lwp.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_matcher_clean:
	rm -f emboss_matcher-*

# EMBOSS needle
emboss_needle: emboss_needle_params emboss_needle_param_detail emboss_needle_dbid emboss_needle_file

emboss_needle_params:
	${PERL} emboss_needle_lwp.pl --params

emboss_needle_param_detail:
	${PERL} emboss_needle_lwp.pl --paramDetail matrix

emboss_needle_dbid:
	${PERL} emboss_needle_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_needle_file:
	${PERL} emboss_needle_lwp.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_needle_clean:
	rm -f emboss_needle-*

# TODO: EMBOSS seqret
emboss_seqret:
	echo 'TODO:' $@

emboss_seqret_clean:
	rm -f emboss_seqret-*

# EMBOSS sixpack
emboss_sixpack: emboss_sixpack_params emboss_sixpack_param_detail emboss_sixpack_dbid emboss_sixpack_file emboss_sixpack_stdin_stdout emboss_sixpack_id_list_file emboss_sixpack_id_list_file_stdin_stdout

emboss_sixpack_params:
	${PERL} emboss_sixpack_lwp.pl --params

emboss_sixpack_param_detail:
	${PERL} emboss_sixpack_lwp.pl --paramDetail codontable

emboss_sixpack_dbid:
	${PERL} emboss_sixpack_lwp.pl --email ${EMAIL} --sequence embl:L12345

emboss_sixpack_file:
	${PERL} emboss_sixpack_lwp.pl --email ${EMAIL} --sequence ../test_data/EMBL_AB000204.fasta

emboss_sixpack_id_list_file:
	${PERL} emboss_sixpack_lwp.pl --email ${EMAIL} --sequence @../test_data/embl_id_list.txt

emboss_sixpack_stdin_stdout:
	cat ../test_data/EMBL_AB000204.fasta | ${PERL} emboss_sixpack_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_sixpack-blah.txt

emboss_sixpack_id_list_file_stdin_stdout:
	cat ../test_data/embl_id_list.txt | ${PERL} emboss_sixpack_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - --sequence @- > emboss_sixpack-list.txt

emboss_sixpack_clean:
	rm -f emboss_sixpack-*

# EMBOSS stretcher
emboss_stretcher: emboss_stretcher_params emboss_stretcher_param_detail emboss_stretcher_dbid emboss_stretcher_file

emboss_stretcher_params:
	${PERL} emboss_stretcher_lwp.pl --params

emboss_stretcher_param_detail:
	${PERL} emboss_stretcher_lwp.pl --paramDetail matrix

emboss_stretcher_dbid:
	${PERL} emboss_stretcher_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_stretcher_file:
	${PERL} emboss_stretcher_lwp.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_stretcher_clean:
	rm -f emboss_stretcher-*

# EMBOSS transeq
emboss_transeq: emboss_transeq_params emboss_transeq_param_detail emboss_transeq_dbid emboss_transeq_file emboss_transeq_stdin_stdout emboss_transeq_id_list_file emboss_transeq_id_list_file_stdin_stdout

emboss_transeq_params:
	${PERL} emboss_transeq_lwp.pl --params

emboss_transeq_param_detail:
	${PERL} emboss_transeq_lwp.pl --paramDetail codontable

emboss_transeq_dbid:
	${PERL} emboss_transeq_lwp.pl --email ${EMAIL} --sequence embl:L12345

emboss_transeq_file:
	${PERL} emboss_transeq_lwp.pl --email ${EMAIL} --sequence ../test_data/EMBL_AB000204.fasta

emboss_transeq_id_list_file:
	${PERL} emboss_transeq_lwp.pl --email ${EMAIL} --sequence @../test_data/embl_id_list.txt

emboss_transeq_stdin_stdout:
	cat ../test_data/EMBL_AB000204.fasta | ${PERL} emboss_transeq_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > emboss_transeq-blah.txt

emboss_transeq_id_list_file_stdin_stdout:
	cat ../test_data/embl_id_list.txt | ${PERL} emboss_transeq_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - --sequence @- > emboss_transeq-list.txt

emboss_transeq_clean:
	rm -f emboss_transeq-*

# EMBOSS water
emboss_water: emboss_water_params emboss_water_param_detail emboss_water_dbid emboss_water_file

emboss_water_params:
	${PERL} emboss_water_lwp.pl --params

emboss_water_param_detail:
	${PERL} emboss_water_lwp.pl --paramDetail matrix

emboss_water_dbid:
	${PERL} emboss_water_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_water_file:
	${PERL} emboss_water_lwp.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

emboss_water_clean:
	rm -f emboss_water-*

# FASTA
fasta: fasta_params fasta_param_detail fasta_file fasta_dbid fasta_stdin_stdout fasta_id_list_file fasta_multifasta_file

fasta_params:
	${PERL} fasta_lwp.pl --params

fasta_param_detail:
	${PERL} fasta_lwp.pl --paramDetail program

fasta_file:
	${PERL} fasta_lwp.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

fasta_dbid:
	${PERL} fasta_lwp.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

fasta_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} fasta_lwp.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > fasta-blah.txt

fasta_id_list_file:
	${PERL} fasta_lwp.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein --outformat ids --outfile - @../test_data/uniprot_id_list.txt

fasta_multifasta_file:
	${PERL} fasta_lwp.pl --email ${EMAIL} --program fasta --database uniprotkb_swissprot --eupper 1.0 --scores 10 --alignments 10 --stype protein --outformat ids --outfile - --multifasta  ../test_data/multi_prot.tfa

fasta_clean:
	rm -f fasta-*

# FASTM
fastm: fastm_params fastm_param_detail fastm_file fastm_stdin_stdout

fastm_params:
	${PERL} fastm_lwp.pl --params

fastm_param_detail:
	${PERL} fastm_lwp.pl --paramDetail program

fastm_file:
	${PERL} fastm_lwp.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein ../test_data/peptides.fasta

fastm_stdin_stdout:
	cat ../test_data/peptides.fasta | ${PERL} fastm_lwp.pl --email ${EMAIL} --program fastm --database uniprotkb_swissprot --expupperlim 1.0 --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > fastm-blah.txt

fastm_clean:
	rm -f fastm-*

# InterProScan
iprscan: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_multifasta_file

iprscan_params:
	${PERL} iprscan_lwp.pl --params

iprscan_param_detail:
	${PERL} iprscan_lwp.pl --paramDetail appl

iprscan_file:
	${PERL} iprscan_lwp.pl --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${PERL} iprscan_lwp.pl --email ${EMAIL} UNIPROT:ABCC9_HUMAN

iprscan_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} iprscan_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > iprscan-blah.txt

iprscan_id_list_file:
	${PERL} iprscan_lwp.pl --email ${EMAIL} --outformat out --outfile - @../test_data/uniprot_id_list.txt

iprscan_multifasta_file:
	${PERL} iprscan_lwp.pl --email ${EMAIL} --outformat out --outfile - --multifasta  ../test_data/multi_prot.tfa

iprscan_clean:
	rm -f iprscan-*

# TODO: InterProScan 5
iprscan5:
	echo 'TODO:' $@

iprscan5_clean:
	rm -f iprscan5-*

# Kalign
kalign: kalign_params kalign_param_detail kalign_file kalign_stdin_stdout

kalign_params:
	${PERL} kalign_lwp.pl --params

kalign_param_detail:
	${PERL} kalign_lwp.pl --paramDetail format

kalign_file:
	${PERL} kalign_lwp.pl --email ${EMAIL} --stype protein ../test_data/multi_prot.tfa

kalign_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} kalign_lwp.pl --email ${EMAIL} --stype protein --quiet --outformat aln-clustalw --outfile - - > kalign-blah.aln

kalign_clean:
	rm -f kalign-*

# lalign
lalign: lalign_params lalign_param_detail lalign_dbid lalign_file

lalign_params:
	${PERL} lalign_lwp.pl --params

lalign_param_detail:
	${PERL} lalign_lwp.pl --paramDetail matrix

lalign_dbid:
	${PERL} lalign_lwp.pl --email ${EMAIL} --stype protein --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

lalign_file:
	${PERL} lalign_lwp.pl --email ${EMAIL} --asequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta --bsequence ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

lalign_clean:
	rm -f lalign-*

# MAFFT
mafft: mafft_params mafft_param_detail mafft_file mafft_stdin_stdout

mafft_params:
	${PERL} mafft_lwp.pl --params

mafft_param_detail:
	${PERL} mafft_lwp.pl --paramDetail matrix

mafft_file:
	${PERL} mafft_lwp.pl --email ${EMAIL} ../test_data/multi_prot.tfa

mafft_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} mafft_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > mafft-blah.aln

mafft_clean:
	rm -f mafft-*

# MUSCLE
muscle: muscle_params muscle_param_detail muscle_file muscle_stdin_stdout

muscle_params:
	${PERL} muscle_lwp.pl --params

muscle_param_detail:
	${PERL} muscle_lwp.pl --paramDetail format

muscle_file:
	${PERL} muscle_lwp.pl --email ${EMAIL} --output clw ../test_data/multi_prot.tfa

muscle_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} muscle_lwp.pl --email ${EMAIL} --output clw --quiet --outformat out --outfile - - > muscle-blah.aln

muscle_clean:
	rm -f muscle-*

# MView
mview: mview_params mview_param_detail mview_file mview_stdin_stdout

mview_params:
	${PERL} mview_lwp.pl --params

mview_param_detail:
	${PERL} mview_lwp.pl --paramDetail outputformat

mview_file:
	${PERL} mview_lwp.pl --email ${EMAIL} --sequence ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt --alignment --ruler --consensus --htmlmarkup off

mview_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.blastp.out.txt | ${PERL} mview_lwp.pl --email ${EMAIL} --alignment --ruler --consensus --htmlmarkup off --quiet --outformat out --outfile - - > mview-blah.aln

mview_clean:
	rm -f mview-*

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout ncbiblast_id_list_file ncbiblast_multifasta_file

ncbiblast_params:
	${PERL} ncbiblast_lwp.pl --params

ncbiblast_param_detail:
	${PERL} ncbiblast_lwp.pl --paramDetail program

ncbiblast_file:
	${PERL} ncbiblast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PERL} ncbiblast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

ncbiblast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} ncbiblast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > ncbiblast-blah.txt

ncbiblast_id_list_file:
	${PERL} ncbiblast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --outformat ids --outfile - @../test_data/uniprot_id_list.txt

ncbiblast_multifasta_file:
	${PERL} ncbiblast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --outformat ids --outfile - --multifasta  ../test_data/multi_prot.tfa

ncbiblast_clean:
	rm -f ncbiblast-*

# Phobius
phobius: phobius_params phobius_param_detail phobius_file phobius_dbid phobius_stdin_stdout

phobius_params:
	${PERL} phobius_lwp.pl --params

phobius_param_detail:
	${PERL} phobius_lwp.pl --paramDetail format

phobius_file:
	${PERL} phobius_lwp.pl --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

phobius_dbid:
	${PERL} phobius_lwp.pl --email ${EMAIL} UNIPROT:ABCC9_HUMAN

phobius_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} phobius_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > phobius-blah.txt

phobius_clean:
	rm -f phobius-*

# TODO: PRANK
prank:
	echo 'TODO:' $@

prank_clean:
	rm -f prank-*

# PSI-BLAST
psiblast: psiblast_params psiblast_param_detail psiblast_file psiblast_dbid psiblast_stdin_stdout

psiblast_params:
	${PERL} psiblast_lwp.pl --params

psiblast_param_detail:
	${PERL} psiblast_lwp.pl --paramDetail matrix

psiblast_file:
	${PERL} psiblast_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psiblast_dbid:
	${PERL} psiblast_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 UNIPROT:ABCC9_HUMAN

psiblast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psiblast_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --quiet --outformat out --outfile - - > psiblast-blah.txt

psiblast_clean:
	rm -f psiblast-*

# PSI-Search
psisearch: psisearch_params psisearch_param_detail psisearch_file psisearch_dbid psisearch_stdin_stdout

psisearch_params:
	${PERL} psisearch_lwp.pl --params

psisearch_param_detail:
	${PERL} psisearch_lwp.pl --paramDetail matrix

psisearch_file:
	${PERL} psisearch_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psisearch_dbid:
	${PERL} psisearch_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 UNIPROT:ABCC9_HUMAN

psisearch_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psisearch_lwp.pl --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --quiet --outformat out --outfile - - > psisearch-blah.txt

psisearch_clean:
	rm -f psisearch-*

# TODO: Readseq
readseq:
	echo 'TODO:' $@

readseq_clean:
	rm -f readseq-*

# TODO: seqcksum
seqcksum:
	echo 'TODO:' $@

seqcksum_clean:
	rm -f seqcksum-*

# T-Coffee
tcoffee: tcoffee_params tcoffee_param_detail tcoffee_file tcoffee_stdin_stdout

tcoffee_params:
	${PERL} tcoffee_lwp.pl --params

tcoffee_param_detail:
	${PERL} tcoffee_lwp.pl --paramDetail matrix

tcoffee_file:
	${PERL} tcoffee_lwp.pl --email ${EMAIL} ../test_data/multi_prot.tfa

tcoffee_stdin_stdout:
	cat ../test_data/multi_prot.tfa | ${PERL} tcoffee_lwp.pl --email ${EMAIL} --quiet --outformat out --outfile - - > tcoffee-blah.aln

tcoffee_clean:
	rm -f tcoffee-*

# WU-BLAST
wublast: wublast_params wublast_param_detail wublast_file wublast_dbid wublast_stdin_stdout wublast_id_list_file wublast_multifasta_file

wublast_params:
	${PERL} wublast_lwp.pl --params

wublast_param_detail:
	${PERL} wublast_lwp.pl --paramDetail program

wublast_file:
	${PERL} wublast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

wublast_dbid:
	${PERL} wublast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

wublast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} wublast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > wublast-blah.txt

wublast_id_list_file:
	${PERL} wublast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --outformat ids --outfile - @../test_data/uniprot_id_list.txt

wublast_multifasta_file:
	${PERL} wublast_lwp.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --outformat ids --outfile - --multifasta  ../test_data/multi_prot.tfa

wublast_clean:
	rm -f wublast-*
