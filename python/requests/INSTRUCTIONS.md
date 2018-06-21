# Python webservice clients

Notes on how to use RESTful clients in Python 2/3 (requests).

## How to start

Clone the repository:

```
git clone https://github.com/ebi-wp/webservice-clients.git
```


External dependencies

To run the clients, you need to install 'requests'

```
pip install requests
```


## Test the results

Run a selected client.

For instance:

```
cd webservice-clients/python/requests
```

### Example: EBI Search

Case 1: get domain details about 'uniprot':

```
python ebeye_requests.py getDomainDetails uniprot
```

Case 2: get all the results of the query 'human' from domain 'hgnc' retrieving the fields 'id' and 'name' with the 'start' parameter '0' and 'size' (number of results) '3':

```
python ebeye_requests.py getResults hgnc human id,name --start 0 --size 3
```

Case 3: get the fields 'id' and 'acc' from domain 'uniprot' for the entry with id 'P01174':

```
python ebeye_requests.py getEntries uniprot P01174 id,acc
```

If you have no root access to your machine you might need to use [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/).


## Documentation

More documentation about the tools in [EBI Tools](https://www.ebi.ac.uk/seqdb/confluence/display/WEBSERVICES/EMBL-EBI+Web+Services).
