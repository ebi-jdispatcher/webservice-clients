# Python webservice clients

Notes on how to use RESTful clients in Python 2 (urllib2).

## How to start

Clone the repository:

```git clone https://github.com/ebi-wp/webservice-clients.git```

```cd webservice-clients```

Install dependencies for Python 2:

```pip install -r requerimentspython2.txt```

External dependencies

To run the clients you need to install (please double check if you have already install xmltramp2 and gzip)

```pip install xmltramp2```

```pip install gzip```

## Test the results

Run selected client.

For instance:

```cd webservice-clients/python/urllib```

### Example: EBI Search

Case 1: get domain details about 'uniprot':

```python ebeye_urllib2.py getDomainDetails uniprot```

Case 2: get all the results of the query 'human' from domain 'hgnc' retrieving the fields 'id' and 'name' with the 'start' parameter '0' and 'size' (number of results) '3':

```python ebeye_urllib2.py getResults hgnc human id,name --start 0 --size 3```

Case 3: get the fields 'id' and 'acc' from domain 'uniprot' for the entry with id 'P01174':

```python ebeye_urllib2.py getEntries uniprot P01174 id,acc```

If you have no root access to your machine you might need to use [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/).

## Documentation

More documnetation about the tools in [EBI Tools](https://www.ebi.ac.uk/seqdb/confluence/display/WEBSERVICES/EMBL-EBI+Web+Services).
