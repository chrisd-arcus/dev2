#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3

# file find_field_headers_clinical_rename.py
#from __future__ import division

""" description
.. module:: **filename**.py
    :members:
    :platform: Unix, OS X
    :synopsis: **synopsis here**
.. moduleauthor:: Author Name <chrisdphd@gmail.com>
"""

__author__ = "Christopher Davies"
__copyright__ = " "
__credits__ = ["FirstName LastName"]
__license__ = " "
__version__ = "0.1"
__maintainer__ = "Christopher Davies"
__email__ = "chrisdphd@gmail.com"
__status__ = "Development"

from sys import argv
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from os.path import exists, isfile
import sys


def workflow(verbose, fh_input, col_csv, col_dict, force):
    """description of workflow
    
    :param <parameter name>: <parameter description>
    :type <parameter name>: <parameter type>
    :returns: <what function returns>
    """

    if col_csv:
        cols = col_csv.split(',') ### making the col_csv string into the cols list
        if verbose:
            listcount = -1
            for col in col_csv.split(','):
                listcount += 1
                str(listcount)
                print("from list", col, listcount)

    if col_dict: ### pulling the first field of col_dict into the cols list
        cols = []
        col_renames = []
        for line in col_dict:
            line = line.strip('\n')
            linetab = line.split('\t')
            cols.append(linetab[0])  ### put the col names to FIND in the list
            col_renames.append(linetab[1])  ### put the col names to OUTPUT in separate list

        if verbose:
            print("COLS    :", cols)
            print("RE-NAMES:", col_renames)

    colnum_dict = {}  ### col names vs the numerical field# we find them in

    linecount=-1
    for line in fh_input:
        linecount += 1
        line = line.strip('\n')
        l0 = line.split('\t')

        if linecount == 0:
            for col in cols:  # the input list that we are looking for
                fieldcount = -1
                if verbose:
                    print("looking for:", str(col))
                found = False
                for field in l0:
                    field = field.strip('\n')
                    fieldcount += 1
                    if col == field:  ### if one of our query fields matches the field in the file...
                        found = True
                        if verbose:
                            print("found", col, "at", fieldcount)
                        colnum_dict[col] = fieldcount  ### make the assignment of field to the column number
                if found == False:
                    if force:
                        colnum_dict[col] = 999999  ### so we can output "NA"
                    else:
                        sys.stderr.write('ERROR: field name not found in file...')
                        print("THIS ONE: ", col, "ERROR'd OUT!")
                        exit(1)
            if verbose:
                print(colnum_dict)

            print('\t'.join(cols))  ### printing here as a header for the output
            if col_dict:
                print('\t'.join(col_renames))  ### printing here as a SECOND, RENAMED header for the output

        else:
            printlist = []
            for col in cols:
                #print("COL:", col)
                #print(colnum_dict.get(col))
                if colnum_dict.get(col) == 999999:
                    printlist.append("NA")
                    #print("NULLING THIS ONE")
                else:
                    printlist.append(l0[colnum_dict.get(col)])
            print('\t'.join(printlist))


def parseCmdlineParams(arg_list=argv):
    """Parses commandline arguments.
    
    :param arg_list: Arguments to parse. Default is argv when called from the command-line.
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
    argparser.add_argument('-d', '--col_dict', help='(incompatible with -n) filename (tsv) that pairs col names to FIND with colnames to OUTPUT as', default=None, type=str, required=False)
    argparser.add_argument('-x', '--force', help='(Flag) force output of header names that are NOT found, populated with "NULL"', action="store_true", required=False)

    argparser.add_argument('-v', '--verbose', help='(Flag) verbose output for error checking', action="store_true", required=False)


    return argparser.parse_args()

def main(args,args_parsed=None):

    #If parsed arguments is passed in, do not parse command-line arguments
    if args_parsed is not None:
        args = args_parsed
    #Else, parse arguments from command-line
    else:
        args = parseCmdlineParams(args)

    fh_input = None  ### not actually used
    if args.stdin:
        fh_input = sys.stdin
    elif args.file:   ### the input tsv file we are pulling columns from
        filename = args.file
        if not exists(filename):
            sys.stderr.write('ERROR: file {} does not exist'.format(filename))
            exit(1)
        if not isfile(filename):
            sys.stderr.write('ERROR: file {} is not a file'.format(filename))
            exit(1)
        fh_input = open(filename, 'r')
    else:
        raise Exception("INPUT source not specified as -c or -f")

    if args.force:
        force = True
    else:
        force = False

    if args.verbose:
        verbose = True
        print("input FILE?:", args.file)
        print("input STDIN?", args.stdin)
        print("actual input:", fh_input)
    else:
        verbose = False

    if args.colnames:
        col_csv = (args.colnames)
        if verbose:
            print(col_csv)

    if args.col_dict:   ### the dictionary tsv file designates column names to pull, and to rename to if desired.
        if args.colnames:
            sys.stderr.write('ERROR: cannot specify both (-n) colnames csv AND (-d) tsv dictionary of colnames/output_names')
            exit(1)
        else:
            dictfile = args.col_dict
            if not exists(dictfile):
                sys.stderr.write('ERROR: file {} does not exist'.format(dictfile))
                exit(1)
            if not isfile(dictfile):
                sys.stderr.write('ERROR: file {} is not a file'.format(dictfile))
                exit(1)
            col_dict = open(dictfile, 'r')
            col_csv = False    # we dont want the csv cmd line input if we have a tsv file.
    else:
        col_dict = False



    #Call workflow for script after parsing command line parameters.
    workflow(verbose, fh_input, col_csv, col_dict, force)

if __name__ == "__main__":
    main(argv)
