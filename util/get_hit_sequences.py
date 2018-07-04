#!/usr/bin/env python
# ======================================================================
#
# Copyright 2009-2018 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ======================================================================
#
# Small utility to get fasta sequences for hit proteins
#

import os
import requests
import click


database_dict = {
    "UNIPROT": "uniprotkb",
    "SP": "uniprotkb",
    "SW": "uniprotkb",
    "TR": "uniprotkb",
    # TODO add other databases
}

def fetch_from_url_or_retry(url, json=True, header=None, post=False, data=None,
                            retry_in=None, wait=1, n_retries=10, stream=False, **params):
    """
    Fetch an url using Requests or retry fetching it if the server is
    complaining with retry_in error. There is a limit to the number of retries.
    Retry code examples: 429, 500 and 503
    :param url: url to be fetched as a string
    :param json: json output
    :param header: dictionary
    :param post: boolean
    :param data: dictionary: only if post is True
    :param retry_in: http codes for retrying
    :param wait: sleeping between tries in seconds
    :param n_retries: number of retry attempts
    :param stream: boolean
    :param params: request.get kwargs.
    :return: url content
    """

    if retry_in is None:
        retry_in = ()
    else:
        assert type(retry_in) is tuple or type(retry_in) is list

    if header is None:
        header = {}
    else:
        assert type(header) is dict

    if json:
        header.update({"Content-Type": "application/json"})
    else:
        if "Content-Type" not in header:
            header.update({"Content-Type": "text/plain"})

    if post:
        if data is not None:
            assert type(data) is dict or type(data) is str
            response = requests.post(url, headers=header, data=data)
        else:
            return None
    else:
        response = requests.get(url, headers=header, params=params, stream=stream)

    if response.ok:
        return response
    elif response.status_code in retry_in and n_retries >= 0:
        time.sleep(wait)
        return fetch_from_url_or_retry(url, json, header, post, data, retry_in, wait,
                                       (n_retries - 1), stream, **params)
    else:
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            print('%s: Unable to retrieve %s for %s',
                  response.status_code, url, e)


@click.command()
@click.option('-i', '--input', 'inputHits', type=str,
              multiple=False, help='Path to input file.')
@click.option('-o', '--output', 'outputFasta', type=str,
              multiple=False, help='Path to output file.')
def cli(inputHits, outputFasta):
    """Small utility to get fasta sequences from a list of hits.
    """
    if inputHits is None:
        print("Run python %s --help for more information." %
              (os.path.basename(__file__)))
        return
    return main(inputHits, outputFasta)


def main(inputHits, outputFasta=None):
    """
    Typically useful when performing a Sequence similarity search and
    a list of hits is generated.

    Hits are expected to be in the format: <db_id>:<accession_id>

    :param inputHits: path to input file
    :param outputFasta: path to output file
    :returns: (side effects) writes output to file if provided,
      otherwise to the stdout
    """

    # Service base URL
    urlroot = 'https://www.ebi.ac.uk/Tools/dbfetch/dbfetch'
    # e.g. https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=uniprotkb;id=P01174;format=default;style=raw

    output = []
    if os.path.isfile(inputHits):
        with open(inputHits, "r") as inlines:
            for line in inlines:
                line = line.strip()
                if ":" in line:
                    db = line.split(":")[0]
                    acc = line.split(":")[1]
                    query = ("?db=%s;id=%s;format=fasta;style=raw"
                             % (database_dict[db], acc))
                    url = urlroot + query
                    r = fetch_from_url_or_retry(url)
                    seq = r.text
                    if outputFasta is not None:
                        output.append(seq)
                    else:
                        print(seq)
                else:
                    print("Hits not in <db_id>:<accession_id> format...")
                    return

        out = open(outputFasta, "w")
        out.write("".join(output))
        out.close()
    else:
        print("Input file %s not available or readable!" % inputHits)


if __name__ == "__main__":
    cli()
