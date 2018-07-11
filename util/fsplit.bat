@echo off

REM IF %1 == "" GOTO USAGE
IF EXIST %2 GOTO DIR_EXISTS

mkdir %2
csplit -f %2/sequence %1 "%%^>%%" "/^>/" "{*}" -s
GOTO END

:USAGE
echo Use: fsplit SEQFILE DESTDIR
echo      Splits SEQFILE into separate files and puts them in DESTDIR
GOTO END

:DIR_EXISTS
echo %2 already exists

:END