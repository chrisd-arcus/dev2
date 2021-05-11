#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3
#/usr/bin/python
#/usr/env/bin python
# file **filename**.py
#from __future__ import division

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
import sys

def add(x, y):
    """Add Function"""
    return x + y


def workflow(verbose, fh, cols):
    """description of workflow
    
    :param <parameter name>: <parameter description>
    :type <parameter name>: <parameter type>
    :returns: <what function returns>
    """
    if verbose:
        print("The addition function: ",(add(2,2)))

    listcount = -1
    for col in cols.split(','):
        listcount += 1
        str(listcount)
        if verbose:
            print("from list", col, listcount)

    col_dict = {}

    linecount=-1
    for line in fh:
        linecount += 1
        line = line.strip('\n')
        l0 = line.split('\t')

        if linecount == 0:
            for col in cols.split(','):  # the input list that we are looking for
                fieldcount = -1
                if verbose:
                    print("looking for:", str(col))
                found = False
                for field in l0:
                    field = field.strip('\n')
                    fieldcount += 1
                    if col == field:
                        found = True
                        if verbose:
                            print("found", col, "at", fieldcount)
                        col_dict[col] = fieldcount
                if found == False:
                    sys.stderr.write('ERROR: field name not found in file...')
                    print("THIS ONE: ", col, "ERROR'd OUT!")
                    exit(1)
            if verbose:
                print(col_dict)

            col_list = []
            col_list = cols.split(',')
            print('\t'.join(col_list))

        else:
            printlist = []
            for col in cols.split(','):
                printlist.append(l0[col_dict.get(col)])
            print('\t'.join(printlist))


def parseCmdlineParams(arg_list=argv):
    """Parses commandline arguments.
    
    :param arg_list: Arguments to parse. Default is argv when called from the
    command-line.
    :type arg_list: list.
    """
    #Create instance of ArgumentParser
    argparser = ArgumentParser(formatter_class=\
        ArgumentDefaultsHelpFormatter, description='cat ~/resource/keep_me_here.tmp1.tab | ~/bin/templates.dir/find_field_headers.py -c -v | less')
    # Script arguments.  Use:
    # argparser.add_argument('--argument',help='help string')
    argparser.add_argument('-f', '--file', help='file to analyse. Format ID<tab>ACTGTGCATGC...etc, on 1 line.', type=str, required=False)
    argparser.add_argument('-c', '--stdin', help='(Flag) info on STDIN to analyse', action="store_true", required=False)
    argparser.add_argument('-n', '--colnames', help='a csv of the column header NAMES to find, in the order desired for printout', type=str, required=False)

    argparser.add_argument('-1', '--int1', help='Integer 1 in math function', default=3, type=int, required=False)
    argparser.add_argument('-2', '--int2', help='Integer 2 in math function', default=4, type=int, required=False)
    argparser.add_argument('-v', '--verbose', help='(Flag) verbose output for errror checking', action="store_true", required=False)


    return argparser.parse_args()

def main(args,args_parsed=None):

    #If parsed arguments is passed in, do not parse command-line arguments
    if args_parsed is not None:
        args = args_parsed
    #Else, parse arguments from command-line
    else:
        args = parseCmdlineParams(args)

    fh = None
    if args.stdin:
        fh = sys.stdin
    elif args.file:   ### the mRNA file
        filename = args.file
        if not exists(filename):
            sys.stderr.write('ERROR: file {} does not exist'.format(filename))
            exit(1)
        if not isfile(filename):
            sys.stderr.write('ERROR: file {} is not a file'.format(filename))
            exit(1)
        fh = open(filename, 'r')
    else:
        raise Exception("INPUT source not specified as -c or -f")

    if args.verbose:
        verbose = True
        print("input FILE?:", args.file)
        print("input STDIN?", args.stdin)
        print("actual input:", fh)
    else:
        verbose = False

    if args.colnames:
        cols = (args.colnames)
        if verbose:
            print(cols)

    #Call workflow for script after parsing command line parameters.
    workflow(verbose, fh, cols)

if __name__ == "__main__":
    main(argv)
