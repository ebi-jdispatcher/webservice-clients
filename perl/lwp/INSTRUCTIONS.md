# Perl webservice Clients
Tool to use REST interface in Perl

### How to use it

Clone the repository:

```git clone https://github.com/ebi-wp/webservice-clients.git```

```cd webservice-clients```

Install dependencies:

In Linux:

```sudo apt install imagemagick```

In Perl:

```sudo cpan install -r perlrequeriments.txt```

### Test the results

Run selected client. 

# For example NCBI Blast:

```cd webservice-clients/perl/lwp```

With one sequence

```perl ncbiblast_lwp.pl --email test@ebi.ac.uk --stype protein --program blastp --database mpro sp:wap_pig```

With multifasta file

```perl ncbiblast_lwp.pl --email test@ebi.ac.uk --stype protein --program blastp --database mpro --multifasta --maxJobs 5 test_seq.txt```

# For example Clustal Omega:

```perl clustalo_lwp.pl --email test@ebi.ac.uk sp:wap_rat,sp:wap_pig,sp:wap_mouse```

# For example Simple Phylogeny:

```perl simple_phylogeny_lwp.pl --email test@ebi.ac.uk test_alig.txt```

# For example Fasta:

With one sequence:

```perl fasta_lwp.pl --email test@ebi.ac.uk --stype protein --program fasta --database uniprotkb sp:wap_pig```

With multifasta file:

```perl fasta_lwp.pl --email test@ebi.ac.uk --stype protein --program fasta --database uniprotkb --multifasta --maxJobs 5 test_seq.txt```


If you have no root access to your machine you might need to use [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/).

### Documentation

More documnetation about the tools in [EBI Tools](https://www.ebi.ac.uk/seqdb/confluence/display/WEBSERVICES/EMBL-EBI+Web+Services)
