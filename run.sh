#!/bin/bash

export TUTO_HWAF_VERSION=20130208
export TUTO_HWAF_OS=linux
export TUTO_HWAF_ARCH=amd64

set -e

function run_tuto() {
    export TUTO_ROOT=`pwd`/tuto
    echo ":: running tutorial in [${TUTO_ROOT}]..."
    if [ -d "$TUTO_ROOT" ]; then
        echo "** directory [$TUTO_ROOT] already exist !"
        return 1
    fi

    /bin/rm -rf $TUTO_ROOT
    /bin/mkdir -p "${TUTO_ROOT}"

    pushd $TUTO_ROOT
    /bin/mkdir local

    pushd local
    fname=hwaf-${TUTO_HWAF_VERSION}-${TUTO_HWAF_OS}-${TUTO_HWAF_ARCH}
    echo ":: fetching [$fname.tar.gz]"
    curl -L \
        http://cern.ch/mana-fwk/downloads/tar/${fname}.tar.gz \
        | tar zxf -
    export HWAF_ROOT=`pwd`
    export PATH=$HWAF_ROOT/bin:$PATH

    popd

    hwaf init work
    pushd work
    echo "::: hwaf: "`which hwaf`
    echo "::: hwaf: "`hwaf version`

    hwaf setup
    echo "::: setup:"
    hwaf show setup
    hwaf pkg create mytools/mypkg

    echo "::: pkg list:"
    hwaf pkg ls

    cat >| src/mytools/mypkg/wscript <<EOF
# -*- python -*-
# automatically generated wscript

import waflib.Logs as msg
from waflib.Utils import subst_vars

PACKAGE = {
    'name': 'mytools/mypkg',
    'author': ["Sebastien Binet"], 
}

def pkg_deps(ctx):
    return

def configure(ctx):
    msg.debug('[configure] package name: '+PACKAGE['name'])
    ctx.load('find_clhep')
    ctx.find_clhep(mandatory=False)
    ctx.start_msg("was clhep found ?")
    ctx.end_msg(ctx.env.HWAF_FOUND_CLHEP)
    if ctx.env.HWAF_FOUND_CLHEP:
        ctx.start_msg("clhep version")
        ctx.end_msg(ctx.env.CLHEP_VERSION)
        msg.info("clhep linkflags: %s" % ctx.env['LINKFLAGS_CLHEP'])
        msg.info("clhep cxxflags: %s" % ctx.env['CXXFLAGS_CLHEP'])

    ctx.load('find_python')
    ctx.find_python(mandatory=True)
    ctx.declare_runtime_env('PYTHONPATH') 
    pypath = subst_vars('\${INSTALL_AREA}/python', ctx.env)
    ctx.env.prepend_value('PYTHONPATH', [pypath])
    return

def build(ctx):
    ctx(features = 'cxx cxxshlib',
        name = 'cxx-hello-world',
        source = 'src/mypkgtool.cxx',
        target = 'hello-world',
        )

    ctx(features     = 'py',
        name         = 'py-hello',
        source       = 'python/pyhello.py python/__init__.py',
        install_path = '\${INSTALL_AREA}/python/mypkg',
        use          = 'cxx-hello-world',
        )
    return
## EOF ##
EOF
    
    hwaf configure

    cat >| src/mytools/mypkg/src/mypkgtool.cxx <<EOF
#include <cmath>

extern "C" {
  
float
calc_hypot(float x, float y) 
{
  return std::sqrt(x*x + y*y);
}

}

// EOF
EOF

    mkdir src/mytools/mypkg/python
    touch src/mytools/mypkg/python/__init__.py
    cat >| src/mytools/mypkg/python/pyhello.py <<EOF
import ctypes
lib = ctypes.cdll.LoadLibrary('libhello-world.so')
if not lib:
    raise RuntimeError("could not find hello-world")

calc_hypot = lib.calc_hypot
calc_hypot.argtypes = [ctypes.c_float]*2
calc_hypot.restype = ctypes.c_float

import sys
sys.stdout.write("hypot(10,20) = %s\n" % calc_hypot(10,20))
sys.stdout.flush()
# EOF #

EOF
    hwaf

    echo "::: echo \$PYTHONPATH..."
    hwaf run echo "PYTHONPATH="\$PYTHONPATH

    echo "::: running py-hello..."
    hwaf run python -c 'import mypkg.pyhello'

    hwaf clean
    hwaf

    echo "::: project deps..."
    hwaf show projects

    echo "::: pkg deps..."
    hwaf show pkg-uses mytools/mypkg

    echo "::: C++ compilation/link flags..."
    hwaf show flags CXXFLAGS LINKFLAGS

    echo "::: constituents of this project..."
    hwaf show constituents
    return 0
}

run_tuto

