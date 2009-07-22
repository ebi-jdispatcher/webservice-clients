# ======================================================================
#
# Test sample SOAP::Lite clients run correctly
#
# ======================================================================

#PERL = perl
PERL = /ebi/extserv/bin/perl/bin/perl
EMAIL = email@example.org

# Run all test sets
all:

# ClustalW 2.0.x
clustalw2: clustalw2_align clustalw2_tree clustalw2_align_stdin_stdout

clustalw2_align:
	${PERL} clustalw2.pl --email ${EMAIL} --align ../test/multi_prot.tfa

clustalw2_tree:
	${PERL} clustalw2.pl --email ${EMAIL} --tree --outputtree nj --kimura ../test/multi_prot.aln

clustalw2_align_stdin_stdout:
	cat ../test/multi_prot.tfa | ${PERL} clustalw2.pl --email ${EMAIL} --align --quiet --outformat toolaln --outfile - - > clustalw2-blah.aln

# FASTA
fasta: fasta_getMatrices fasta_getPrograms fasta_getDatabases fasta_getStats fasta_getFilters fasta_file fasta_dbid fasta_stdin_stdout

fasta_getMatrices:
	${PERL} fasta.pl --getMatrices

fasta_getPrograms:
	${PERL} fasta.pl --getPrograms

fasta_getDatabases:
	${PERL} fasta.pl --getDatabases

fasta_getStats:
	${PERL} fasta.pl --getStats

fasta_getFilters:
	${PERL} fasta.pl --getFilters

fasta_file:
	${PERL} fasta.pl --email ${EMAIL} --program fasta3 --database swissprot --eupper 1.0 --scores 10 --alignments 10 ../test/SWISSPROT_ABCC9_HUMAN.fasta

fasta_dbid:
	${PERL} fasta.pl --email ${EMAIL} --program fasta3 --database swissprot --eupper 1.0 --scores 10 --alignments 10 SWISSPROT:ABCC9_HUMAN

fasta_stdin_stdout:
	cat ../test/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} fasta.pl --email ${EMAIL} --program fasta3 --database swissprot --eupper 1.0 --scores 10 --alignments 10 --quiet --outformat tooloutput --outfile - - > fasta-blah.txt

# Kalign
kalign: kalign_file kalign_stdin_stdout

kalign_file:
	${PERL} kalign.pl --email ${EMAIL} --moltype P ../test/multi_prot.tfa

kalign_stdin_stdout:
	cat ../test/multi_prot.tfa | ${PERL} kalign.pl --email ${EMAIL} --moltype P --quiet --outformat tooloutput --outfile - - > kalign-blah.aln

# MAFFT
mafft: mafft_file mafft_stdin_stdout

mafft_file:
	${PERL} mafft.pl --email ${EMAIL} ../test/multi_prot.tfa

mafft_stdin_stdout:
	cat ../test/multi_prot.tfa | ${PERL} mafft.pl --email ${EMAIL} --quiet --outformat tooloutput --outfile - - > mafft-blah.aln

# MUSCLE
muscle: muscle_file muscle_stdin_stdout

muscle_file:
	${PERL} muscle.pl --email ${EMAIL} --output clw ../test/multi_prot.tfa

muscle_stdin_stdout:
	cat ../test/multi_prot.tfa | ${PERL} muscle.pl --email ${EMAIL} --output clw --quiet --outformat tooloutput --outfile - - > muscle-blah.aln

# NCBI BLAST
ncbiblast: ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout

ncbiblast_file:
	${PERL} ncbiblast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --numal 10 ../test/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PERL} ncbiblast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --numal 10 SWISSPROT:ABCC9_HUMAN

ncbiblast_stdin_stdout:
	cat ../test/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} ncbiblast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --numal 10 --quiet --outformat tooloutput --outfile - - > ncbiblast-blah.txt

# PSI-BLAST
psiblast: psiblast_file psiblast_dbid psiblast_stdin_stdout

psiblast_file:
	${PERL} psiblast.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 ../test/SWISSPROT_ABCC9_HUMAN.fasta

psiblast_dbid:
	${PERL} psiblast.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 SWISSPROT:ABCC9_HUMAN

psiblast_stdin_stdout:
	cat ../test/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psiblast.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 --quiet --outformat tooloutput --outfile - - > psiblast-blah.txt

# PSI-Search
psisearch: psisearch_file psisearch_dbid psisearch_stdin_stdout

psisearch_file:
	${PERL} psisearch.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 ../test/SWISSPROT_ABCC9_HUMAN.fasta

psisearch_dbid:
	${PERL} psisearch.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 SWISSPROT:ABCC9_HUMAN

psisearch_stdin_stdout:
	cat ../test/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} psisearch.pl --email ${EMAIL} --database swissprot --scores 10 --align 10 --quiet --outformat tooloutput --outfile - - > psisearch-blah.txt

# T-Coffee
tcoffee: tcoffee_file tcoffee_stdin_stdout

tcoffee_file:
	${PERL} tcoffee.pl --email ${EMAIL} ../test/multi_prot.tfa

tcoffee_stdin_stdout:
	cat ../test/multi_prot.tfa | ${PERL} tcoffee.pl --email ${EMAIL} --quiet --outformat tooloutput --outfile - - > tcoffee-blah.aln

# WU-BLAST
wublast: wublast_getMatrices wublast_getPrograms wublast_getDatabases wublast_getSensitivity wublast_getSort wublast_getStats wublast_getXmlFormats wublast_getFilters wublast_file wublast_dbid wublast_stdin_stdout

wublast_getMatrices:
	${PERL} wublast.pl --getMatrices

wublast_getPrograms:
	${PERL} wublast.pl --getPrograms

wublast_getDatabases:
	${PERL} wublast.pl --getDatabases

wublast_getSensitivity:
	${PERL} wublast.pl --getSensitivity

wublast_getSort:
	${PERL} wublast.pl --getSort

wublast_getStats:
	${PERL} wublast.pl --getStats

wublast_getXmlFormats:
	${PERL} wublast.pl --getXmlFormats

wublast_getFilters:
	${PERL} wublast.pl --getFilters

wublast_file:
	${PERL} wublast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --alignments 10 ../test/SWISSPROT_ABCC9_HUMAN.fasta

wublast_dbid:
	${PERL} wublast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --alignments 10 SWISSPROT:ABCC9_HUMAN

wublast_stdin_stdout:
	cat ../test/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} wublast.pl --email ${EMAIL} --program blastp --database swissprot --scores 10 --alignments 10 --quiet --outformat tooloutput --outfile - - > wublast-blah.txt
