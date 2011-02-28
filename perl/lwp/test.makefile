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
all: clustalw2 fasta fastm iprscan kalign mafft muscle ncbiblast psiblast psisearch tcoffee wublast
# TODO: dbfetch prank

clean: clustalw2_clean fasta_clean fastm_clean iprscan_clean kalign_clean mafft_clean muscle_clean ncbiblast_clean psiblast_clean psisearch_clean tcoffee_clean wublast_clean

# ClustalW 2.0.x
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

dbfetch_fetchData:
	${PERL} dbfetch_lwp.pl fetchData 'uniprotkb:wap_rat' > dbfetch-fetchData.txt

dbfetch_fetchBatch:
	${PERL} dbfetch_lwp.pl fetchBatch uniprotkb 'wap_rat,wap_mouse' > dbfetch-fetchBatch.txt

dbfetch_clean:
	rm -f dbfetch-*

# EMBOSS matcher
emboss_matcher: emboss_matcher_params emboss_matcher_param_detail emboss_matcher_dbid
# TODO: emboss_matcher_file

emboss_matcher_params:
	${PERL} emboss_matcher_lwp.pl --params

emboss_matcher_param_detail:
	${PERL} emboss_matcher_lwp.pl --paramDetail matrix

emboss_matcher_dbid:
	${PERL} emboss_matcher_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_matcher_clean:
	rm -f emboss_matcher-*

# EMBOSS needle
emboss_needle: emboss_needle_params emboss_needle_param_detail emboss_needle_dbid
# TODO: emboss_needle_file

emboss_needle_params:
	${PERL} emboss_needle_lwp.pl --params

emboss_needle_param_detail:
	${PERL} emboss_needle_lwp.pl --paramDetail matrix

emboss_needle_dbid:
	${PERL} emboss_needle_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_needle_clean:
	rm -f emboss_needle-*

# EMBOSS stretcher
emboss_stretcher: emboss_stretcher_params emboss_stretcher_param_detail emboss_stretcher_dbid
# TODO: emboss_stretcher_file

emboss_stretcher_params:
	${PERL} emboss_stretcher_lwp.pl --params

emboss_stretcher_param_detail:
	${PERL} emboss_stretcher_lwp.pl --paramDetail matrix

emboss_stretcher_dbid:
	${PERL} emboss_stretcher_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

emboss_stretcher_clean:
	rm -f emboss_stretcher-*

# EMBOSS water
emboss_water: emboss_water_params emboss_water_param_detail emboss_water_dbid
# TODO: emboss_water_file

emboss_water_params:
	${PERL} emboss_water_lwp.pl --params

emboss_water_param_detail:
	${PERL} emboss_water_lwp.pl --paramDetail matrix

emboss_water_dbid:
	${PERL} emboss_water_lwp.pl --email ${EMAIL} --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

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
lalign: lalign_params lalign_param_detail lalign_dbid
# TODO: lalign_file

lalign_params:
	${PERL} lalign_lwp.pl --params

lalign_param_detail:
	${PERL} lalign_lwp.pl --paramDetail matrix

lalign_dbid:
	${PERL} lalign_lwp.pl --email ${EMAIL} --stype protein --asequence uniprot:wap_rat --bsequence uniprot:wap_mouse

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

# NCBI BLAST
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

# TODO PRANK
prank:

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
