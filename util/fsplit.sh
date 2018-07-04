#!/bin/sh
# split fasta file into separate sequence files
#

if [ $# -gt 1 ]
then
 seqfile="$1"
 destdir="$2"
else
 echo "Use: fsplit SEQFILE DESTDIR"
 echo "     Splits fasta file SEQFILE into separate files in DESTDIR folder"
 exit
fi

mkdir $2
csplit -f $destdir/sequence $seqfile "%^>%" "/^>/" "{*}" -s
