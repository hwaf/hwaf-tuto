hwaf-tuto
=========

``hwaf-tuto`` is a simple tutorial to show how to install ``hwaf`` and
use it.

## Installation

``hwaf`` is a ``Go`` binary produced by the [Go toolchain](http://golang.org).
So, if you have already the ``Go`` toolchain installed (see
[here](http://golang.org/doc/install.html) for instructions) you just have to
do:

```sh
$ go get github.com/hwaf/hwaf
```

to get the latest ``hwaf`` tool (and its ``git`` goodies) installed
and ready.


Packaged up binaries for ``hwaf`` are also available [here](http://cern.ch/hwaf/downloads/tar).
Untar under some directory like so (for linux 64b):

```sh
$ mkdir local
$ cd local
$ curl -L \
  http://cern.ch/hwaf/downloads/tar/hwaf-20130208-linux-amd64.tar.gz \
  | tar zxf -
$ export HWAF_ROOT=`pwd`
$ export PATH=$HWAF_ROOT/bin:$PATH
```

## Getting started

The central tool in ``hwaf`` is the concept of the workarea, where
locally checked out packages will live.

### Introduction
To create such a workarea:

```sh
$ cd dev
# create a workarea named 'work'
$ hwaf init work
$ cd work
```

``hwaf`` supports multi-projects builds, that is: staged builds.
When you create a workarea, you can instruct it to use the definitions
and objects defined by parent projects, using the ``hwaf setup``
command:

```sh
$ cd work
$ hwaf setup -p /path/to/a/project/install
```

Simple builds, such as our tutorial, don't need that, so just do:

```sh
$ cd work
$ hwaf setup
$ hwaf show setup
workarea=/home/binet/dev/work
cmtcfg=x86_64-archlinux-gcc47-opt
projects=
```

### Configure the workarea
We can run the ``configure`` command to test whether all
dependencies are installed and generate the bootstrap code to be able
to compile:

```sh
$ hwaf configure
Setting top to                           : /home/binet/dev/work 
Setting out to                           : /home/binet/dev/work/__build__ 
Manifest file                            : /home/binet/dev/work/.hwaf/local.conf 
Manifest file processing                 : ok 
Checking for 'g++' (c++ compiler)        : g++ 
Checking for 'gcc' (c compiler)          : gcc 
================================================================================
project                                  : work-0.0.1 
prefix                                   : install-area 
pkg dir                                  : src 
variant                                  : x86_64-archlinux-gcc47-opt 
arch                                     : x86_64 
OS                                       : archlinux 
compiler                                 : gcc47 
build-type                               : opt 
projects deps                            : None 
install-area                             : install-area 
njobs-max                                : 2 
================================================================================
[...]

```

## Anatomy of a wscript file

The equivalent of the good ol' ``Makefile`` for ``hwaf`` is the
``wscript`` file.
It is (ATM) a python file with a few mandatory functions.
``hwaf`` ships with a command to create a new package.
Let's do that:

```sh
$ cd work
$ hwaf pkg create mytools/mypkg
$ hwaf pkg ls
src/mytools/mypkg (local)

$ cat src/mytools/mypkg/wscript
```

```python
# -*- python -*-
# automatically generated wscript

import waflib.Logs as msg

PACKAGE = {
    'name': 'mytools/mypkg',
    'author': ["Sebastien Binet"], 
}

def pkg_deps(ctx):
    # put your package dependencies here.
    # e.g.:
    # ctx.use_pkg('AtlasPolicy')
    return

def configure(ctx):
    msg.debug('[configure] package name: '+PACKAGE['name'])
    return

def build(ctx):
    # build artifacts
    # e.g.:
    # ctx.build_complib(
    #    name = 'mypkg',
    #    source = 'src/*.cxx src/components/*.cxx',
    #    use = ['lib1', 'lib2', 'ROOT', 'boost', ...],
    # )
    # ctx.install_headers()
    # ctx.build_pymodule(source=['python/*.py'])
    # ctx.install_joboptions(source=['share/*.py'])
    return
```

### pkg_deps
``pkg_deps`` is where one lists the package dependencies:
- build tools to use,
- external binaries, external libraries, ...
- 3rd-party ``hwaf`` build utils, ...
- packages defining new build rules, ...

The argument to this function is a ``waf.Context`` object which:
- encapsulates the current environment of the build, 
- gives access to the file system
- gives access to build/configure functions

Our simple ``mytools/mypkg`` package does not have any dependency, so
nothing is required there.

### configure
``configure`` is where one configures the package or project.
There, we can discover external libraries/binaries, load new build
tools/functions and/or define new environment variables.

Let's try to detect whether our system has ``CLHEP`` installed but
don't fail the build if it does not find it.

Also, our package will build a ``C++`` library with a few symbols
exported w/o any mangling so that it can be imported and used from
``python``.
We then have to configure our package to check whether ``python`` can
be detected, and declare the ``PYTHONPATH`` environment variable as a
runtime one (so the runtime subshell can be properly setup) and add
the directory where our python files will be installed to the
``PYTHONPATH`` variable.

Let's modify ``configure``:

```python
def configure(ctx):
    ctx.load('find_clhep')
    ctx.find_clhep(mandatory=False)
    ctx.start_msg("was clhep found ?")
    ctx.end_msg(ctx.env.HWAF_FOUND_CLHEP)
    if ctx.env.HWAF_FOUND_CLHEP:
        ctx.start_msg("clhep version")
        ctx.end_msg(ctx.env.CLHEP_VERSION)
        msg.info("clhep linkflags: %s" % ctx.env['LINKFLAGS_CLHEP'])
        msg.info("clhep cxxflags: %s" % ctx.env['CXXFLAGS_CLHEP'])
    
    from waflib.Utils import subst_vars
    ctx.load('find_python')
    ctx.find_python(mandatory=True)
    ctx.declare_runtime_env('PYTHONPATH') 
    pypath = subst_vars('${INSTALL_AREA}/python', ctx.env)
    ctx.env.prepend_value('PYTHONPATH', [pypath])
```

Note that, as we added a new package, we *must* re-configure the
workarea:

```sh
$ hwaf configure
[...]
Checking for program clhep-config        : /usr/bin/clhep-config 
Checking for '/usr/bin/clhep-config'     : yes 
Found clhep at                           : (local environment) 
Checking clhep version                   : ok 
clhep version                            : 2.1.3.1 
was clhep found ?                        : ok 
clhep version                            : 2.1.3.1 
clhep linkflags: ['-Wl,-O1,--sort-common,--as-needed,-z,relro']
clhep cxxflags:  []
Checking for program python2             : /usr/bin/python2 
checking for __extern_always_inline      : ok 
Checking for program python              : /usr/bin/python2 
python executable '/usr/bin/python2' differs from system '/usr/bin/python'
Checking for python version              : (2, 7, 3, 'final', 0) 
Checking for library python2.7 in LIBDIR : yes 
Checking for program /usr/bin/python2-config,python2.7-config,python-config-2.7,python2.7m-config : /usr/bin/python2-config 
Checking for header Python.h             : yes 
'configure' finished successfully (2.058s)
```

### build
``build`` is where one declares the build targets.

Let's create a simple shared library which will compute some float quantity:

```sh
$ touch src/mytools/mypkg/src/mypkgtool.cxx
```

```c++
#include <cmath>

extern "C" {
  
float
calc_hypot(float x, float y) 
{
  return std::sqrt(x*x + y*y);
}

}

// EOF
```

```sh
$ mkdir src/mytools/mypkg/python
$ touch src/mytools/mypkg/python/pyhello.py
```

```python
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
```

and modify the ``build`` function like so:

```python
def build(ctx):
    ctx(features = 'cxx cxxshlib',
        name     = 'cxx-hello-world',
        source   = 'src/mypkgtool.cxx',
        target   = 'hello-world',
        )

    ctx(features     = 'py',
        name         = 'py-hello',
        source       = 'python/pyhello.py python/__init__.py',
        install_path = '${INSTALL_AREA}/python/mypkg',
        use          = 'cxx-hello-world',
        )
    return
```

Rebuild and run:
```sh
$ hwaf
[...]
$ hwaf run python -c 'import mypkg.pyhello'
hypot(10,20) = 22.360679626464844
```

Note that we used the underlying features of ``waf`` to build and
install the python module and the ``C++`` library.
This could be packaged up in a nice function instead.

### Queries

At the moment, a few queries have been implemented:

```sh
# list the parent project of the current project
$ hwaf show projects
project dependency list for [work] (#projs=0)
work
'show-projects' finished successfully (0.015s)

# list the dependencies of a given package
$ hwaf show pkg-uses mytools/mypkg
package dependency list for [mytools/mypkg] (#pkgs=0)
mytools/mypkg
'show-pkg-uses' finished successfully (0.015s)

# print the value of some flags: C++ compilation, link, shared-lib
$ hwaf show flags CXXFLAGS LINKFLAGS
CXXFLAGS=['-O2', '-m64']
LINKFLAGS=[]

# print the constituents of a project
$ hwaf show constituents
cxx-hello-world 
py-hello 
```
