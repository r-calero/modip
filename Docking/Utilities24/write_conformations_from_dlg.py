#!/usr/bin/env python
#
# 
#
# $Header: /opt/cvs/python/packages/share1.5/AutoDockTools/Utilities24/write_conformations_from_dlg.py,v 1.1 2008/02/28 18:53:51 rhuey Exp $
#
# $Id: write_conformations_from_dlg.py,v 1.1 2008/02/28 18:53:51 rhuey Exp $
#
import os

from MolKit import Read
from AutoDockTools.Docking import Docking


if __name__ == '__main__':
    import sys
    import getopt


    def usage():
        "Print helpful, accurate usage statement to stdout."
        print "Usage: write_conformations_from_dlg.py -d directory"
        print
        print "    Description of command..."
        print "         -d     docking filename"
        print "    Optional parameters:"
        print "        [-o]    output file stem"
        print "        (default is ligandname. Outputfiles are named 'stem' plus '_num.pdbq[t]')"
        print "        [-v]    verbose output"


    # process command arguments
    try:
        opt_list, args = getopt.getopt(sys.argv[1:], 'd:o:vh')
    except getopt.GetoptError, msg:
        print 'write_conformations_from_dlg.py: %s' %msg
        usage()
        sys.exit(2)

    # initialize required parameters
    #-d: docking log filename
    docking_filename =  None

    # initialize optional parameter
    #-o output_stem
    output_stem = None
    #-v verbose best only
    verbose = False

    #'d:bvh'
    for o, a in opt_list:
        #print "o=", o, " a=", a
        if o in ('-d', '--d'):
            docking_filename = a
            if verbose: print 'set docking_filename to ', a
        if o in ('-o', '--o'):
            output_stem = a
            if verbose: print 'set output_stem to ', a
        if o in ('-v', '--v'):
            verbose = True
            if verbose: print 'set verbose to ', True
        if o in ('-h', '--'):
            usage()
            sys.exit()

    if not docking_filename:
        print 'write_conformations_from_dlg: docking_filename must be specified.'
        usage()
        sys.exit()


    d = Docking()
    d.readDlg(docking_filename)
    lines = d.dlo_list[0].parser.reDict['DOCKED: ']['lines']
    num_lines = lines.index("DOCKED: ENDMDL\n")
    num_confs = len(d.ch.conformations)
    ext = '.pdbq'
    if d.version==4.0:
        ext = '.pdbqt'
        
    if output_stem is None:
        output_stem = d.ligMol.name

    for ix in range(num_confs):
        outputfilename = output_stem + '_' + str(ix+1) + ext
        fptr = open(outputfilename, 'w')
        for jx in range(num_lines):
            index = ix*num_lines +jx
            rec = lines[index]
            fptr.write(rec[8:])
        fptr.close()
        if verbose:
            print "wrote ", outputfilename


# To execute this command type:
# write_conformations_from_dlg.py -d docking_filename 
# optional arguments
# -o outputfile_stem (default is ligandname)
