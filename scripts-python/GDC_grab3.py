#! /usr/bin/python3
# file **filename**.py
from __future__ import division

""" description
.. module:: **filename**.py
    :members:
    :platform: Unix, OS X
    :synopsis: **synopsis here**
.. moduleauthor:: Author Name <chrisdphd@gmail.com>
"""

__author__ = "Christopher Davies"
__copyright__ = "Copyright 2020, ChrisD"
__credits__ = ["FirstName LastName"]
__license__ = "Copyright"
__version__ = "0.1"
__maintainer__ = "Christopher Davies"
__email__ = "chrisdphd@gmail.com"
__status__ = "Development"

from sys import argv
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from os.path import exists, isfile
import requests
import json
import re
import sys


def workflow(file_id_list, endpoint):
    data_endpt = "https://api.gdc.cancer.gov/"+endpoint

    ids = [
        file_id_list
    ]

    params = {"ids": ids}

    response = requests.post(data_endpt,
                             data=json.dumps(params),
                             headers={
                                 "Content-Type": "application/json"
                             })

    response_head_cd = response.headers["Content-Disposition"]

    file_name = re.findall("filename=(.+)", response_head_cd)[0]

    with open(file_name, "wb") as output_file:
    #with open(sample_id+"_"+file_name, "wb") as output_file:
        output_file.write(response.content)


def parseCmdlineParams(arg_list=argv):
    """Parses commandline arguments.

    :param arg_list: Arguments to parse. Default is argv when called from the
    command-line.
    :type arg_list: list.
    """
    # Create instance of ArgumentParser
    argparser = ArgumentParser(formatter_class= \
                                   ArgumentDefaultsHelpFormatter,
                               description='sends 3 values to GDC api, and returns a re-named file')
    argparser.add_argument('-f', '--file', help='tsv File to process', type=str, required=False)
    argparser.add_argument('-c', '--stdin', help='(Flag) tsv Data on STDIN to process', action="store_true", required=False)

    argparser.add_argument('-1', '--sampleid', help='User ID of the sample name', type=str, required=False)
    argparser.add_argument('-2', '--fileid', help='file UUID', type=str, required=False)
    argparser.add_argument('-3', '--filename', help='file UUID', type=str, required=False)
    argparser.add_argument('-4', '--searchstring', help='search string required in filename', type=str, required=False)
    argparser.add_argument('-5', '--endpoint', help='the "endpoint" (type of data to retrieve from GDC). only data works', type=str, required=False)

    return argparser.parse_args()


def main(args, args_parsed=None):
    # If parsed arguments is passed in, do not parse command-line arguments
    if args_parsed is not None:
        args = args_parsed
    # Else, parse arguments from command-line
    else:
        args = parseCmdlineParams(args)

    if args.endpoint:
        endpoint = args.endpoint
    else:
        endpoint = "data"

    if args.searchstring:
        searchstring = args.searchstring

    fh = None
    if args.stdin:
        filename = sys.stdin
    elif args.file:
        filename = args.file
        if not exists(filename):
            print('ERROR: file {} does not exist'.format(filename))
            exit(1)
        if not isfile(filename):
            print('ERROR: file {} is not a file'.format(filename))
            exit(1)
    else:
        print('ERROR: Need to use -f to specify a file, or -c for STDIN')
        exit(1)

    file_id_list = []
    try:
        fh = open(filename, 'r')
        for line in fh:  ### sending 1 line at a time from filehandle to funct
            line = line.strip('\n')
            tabs = line.split('\t')
            sample_id = tabs[0] ### not used yet. relying on input tsv for lookup
            file_id = tabs[1]
            file_name = tabs[2]

            if args.searchstring:
                if searchstring in file_name:
                    file_id_list.append(file_id)
            else:
                file_id_list.append(file_id)

        workflow(file_id_list, endpoint)

    except Exception as e:
        print('Exception occurred trying to process file {}. Exception: {}'
              .format(filename, e.message or e))


if __name__ == "__main__":
    main(argv)



