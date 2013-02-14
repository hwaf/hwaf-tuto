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
$ go get github.com/mana-fwk/git-tools/...
$ go get github.com/mana-fwk/hwaf
$ hwaf self init
```

to get the latest ``hwaf`` tool (and its ``git`` goodies) installed
and ready.


Packaged up binaries for ``hwaf`` are also available [here](http://cern.ch/mana-fwk/downloads/tar).
Untar under some directory like so (for linux 64b):

```sh
$ mkdir local
$ cd local
$ curl -L \
  http://cern.ch/mana-fwk/downloads/tar/hwaf-20130130-linux-amd64.tar.gz \
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

### Create a workarea
We'll first check out a few test packages from github prepared for
this tutorial:

```sh
$ cd work
$ hwaf pkg co git://github.com/mana-fwk/hwaf-tests-pkg-settings pkg-settings
$ hwaf pkg ls
src/pkg-settings (git)

$ hwaf pkg co git://github.com/mana-fwk/hwaf-tests-pkg-aa pkg-aa
$ hwaf pkg co git://github.com/mana-fwk/hwaf-tests-pkg-ab pkg-ab
$ hwaf pkg co git://github.com/mana-fwk/hwaf-tests-pkg-ac pkg-ac

$ hwaf pkg ls
src/pkg-settings (git)                             
src/pkg-aa (git)
src/pkg-ac (git)
src/pkg-ab (git)
```

The ``hwaf pkg co`` retrieved and installed the packages' sources
under the ``src`` directory.
Likewise, ``hwaf`` will build the artifacts under the ``__build__``
directory and will install everything under the ``install-area``
directory.

This can be modified of course, but following "convention over
configuration" is usually better.

### Configure the workarea
Then, we can run the ``configure`` command to test whether all
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

### Building targets
As everything went smoothly, we can heed towards building the objects
and targets:

```sh
$ hwaf build
Waf: Entering directory `/home/binet/dev/work/__build__'
ROOT-home: /usr
ROOT-home: /usr
ROOT-home: /usr
[1/8] cxx: src/pkg-aa/src/pkg-aa.cxx -> __build__/src/pkg-aa/src/pkg-aa.cxx.1.o
[2/8] cxx: src/pkg-ab/src/pkg-ab.cxx -> __build__/src/pkg-ab/src/pkg-ab.cxx.1.o
[3/8] cxx: src/pkg-ac/src/pkg-ac.cxx -> __build__/src/pkg-ac/src/pkg-ac.cxx.1.o
[4/8] cxxshlib: __build__/src/pkg-aa/src/pkg-aa.cxx.1.o -> __build__/src/pkg-aa/libpkg-aa.so
[5/8] symlink_tsk: __build__/src/pkg-aa/libpkg-aa.so -> __build__/.install_area/lib/libpkg-aa.so
[6/8] cxxshlib: __build__/src/pkg-ab/src/pkg-ab.cxx.1.o -> __build__/src/pkg-ab/libpkg-ab.so
[7/8] symlink_tsk: __build__/src/pkg-ab/libpkg-ab.so -> __build__/.install_area/lib/libpkg-ab.so
[8/8] cxxprogram: __build__/src/pkg-ac/src/pkg-ac.cxx.1.o -> __build__/src/pkg-ac/pkg-ac
Waf: Leaving directory `/home/binet/dev/work/__build__'
'build' finished successfully (1.234s)
```

And then install like so:
```sh
$ hwaf install
Waf: Entering directory `/home/binet/dev/work/__build__'
ROOT-home: /usr
- install install-area/include/pkg-aa/h1d.hh (from src/pkg-aa/pkg-aa/h1d.hh)
ROOT-home: /usr
- install install-area/include/pkg-ab/h1d.hh (from src/pkg-ab/pkg-ab/h1d.hh)
ROOT-home: /usr
- install install-area/include/pkg-aa/h1d.hh (from src/pkg-aa/pkg-aa/h1d.hh)
- install install-area/include/pkg-ab/h1d.hh (from src/pkg-ab/pkg-ab/h1d.hh)
+ install install-area/project.info (from __build__/project.info)
+ install install-area/share/hwaf/__hwaf_module__work.py (from __build__/__hwaf_module__work.py)
+ install install-area/lib/libpkg-aa.so (from __build__/src/pkg-aa/libpkg-aa.so)
+ install install-area/lib/libpkg-ab.so (from __build__/src/pkg-ab/libpkg-ab.so)
+ install /home/binet/dev/work/install-area/bin/pkg-ac (from __build__/src/pkg-ac/pkg-ac)
Waf: Leaving directory `/home/binet/dev/work/__build__'
- install install-area/python/pkgaa.py (from src/pkg-aa/python/pkgaa.py)
'install' finished successfully (0.066s)
```

### Usual workflow
As this (build+install) is such a mundane combination of commands, a
convenience wrapper is provided:

```sh
$ hwaf
Waf: Entering directory `/home/binet/dev/work/__build__'
ROOT-home: /usr
ROOT-home: /usr
ROOT-home: /usr
[1/8] cxx: src/pkg-aa/src/pkg-aa.cxx -> __build__/src/pkg-aa/src/pkg-aa.cxx.1.o
[2/8] cxx: src/pkg-ab/src/pkg-ab.cxx -> __build__/src/pkg-ab/src/pkg-ab.cxx.1.o
[3/8] cxx: src/pkg-ac/src/pkg-ac.cxx -> __build__/src/pkg-ac/src/pkg-ac.cxx.1.o
[4/8] cxxshlib: __build__/src/pkg-aa/src/pkg-aa.cxx.1.o -> __build__/src/pkg-aa/libpkg-aa.so
[5/8] cxxshlib: __build__/src/pkg-ab/src/pkg-ab.cxx.1.o -> __build__/src/pkg-ab/libpkg-ab.so
[6/8] symlink_tsk: __build__/src/pkg-aa/libpkg-aa.so -> __build__/.install_area/lib/libpkg-aa.so
[7/8] symlink_tsk: __build__/src/pkg-ab/libpkg-ab.so -> __build__/.install_area/lib/libpkg-ab.so
[8/8] cxxprogram: __build__/src/pkg-ac/src/pkg-ac.cxx.1.o -> __build__/src/pkg-ac/pkg-ac
Waf: Leaving directory `/home/binet/dev/work/__build__'
'build' finished successfully (1.163s)
Waf: Entering directory `/home/binet/dev/work/__build__'
ROOT-home: /usr
- install install-area/include/pkg-aa/h1d.hh (from src/pkg-aa/pkg-aa/h1d.hh)
ROOT-home: /usr
- install install-area/include/pkg-ab/h1d.hh (from src/pkg-ab/pkg-ab/h1d.hh)
ROOT-home: /usr
- install install-area/include/pkg-aa/h1d.hh (from src/pkg-aa/pkg-aa/h1d.hh)
- install install-area/include/pkg-ab/h1d.hh (from src/pkg-ab/pkg-ab/h1d.hh)
+ install install-area/project.info (from __build__/project.info)
+ install install-area/share/hwaf/__hwaf_module__work.py (from __build__/__hwaf_module__work.py)
+ install install-area/lib/libpkg-aa.so (from __build__/src/pkg-aa/libpkg-aa.so)
+ install install-area/lib/libpkg-ab.so (from __build__/src/pkg-ab/libpkg-ab.so)
+ install /home/binet/dev/work/install-area/bin/pkg-ac (from __build__/src/pkg-ac/pkg-ac)
Waf: Leaving directory `/home/binet/dev/work/__build__'
- install install-area/python/pkgaa.py (from src/pkg-aa/python/pkgaa.py)
'install' finished successfully (0.038s)

```

We can now test a bit the artifacts produced as the result of the
build.
``pkg-aa`` produced a shared library ``lib-pkgaa`` and a python module
``pkgaa``.
Let's try out the python module:

```sh
$ hwaf shell
[hwaf] $ python -c 'import pkgaa'
hello from pkgaa
[hwaf] $ ^D
$ 
```

``hwaf`` manages the environment produced or modified by a project (or
workarea) and allows the user to step into it, without modifying the
parent environment, via the ``hwaf shell`` command to spawn an
interactive subshell, or via ``hwaf run some-command`` command:

```sh
$ hwaf run python -c 'import pkgaa'
hello from pkgaa
'run' finished successfully (0.108s)
```

This is actual proof the environment has been modified, _i.e._ the
``$PYTHONPATH`` environment variable has been adjusted to encompass
the default installation area of the workarea.

## Binary distributions

Once a project has been built, we can distribute it in binary form:

```sh
$ hwaf bdist
$ tar zft work-20130130-x86_64-archlinux-gcc47-opt.tar.gz
work-20130130/
work-20130130/lib/
work-20130130/lib/libpkg-aa.so
work-20130130/lib/libpkg-ab.so
work-20130130/include/
work-20130130/include/pkg-aa/
work-20130130/include/pkg-aa/h1d.hh
work-20130130/include/pkg-ab/
work-20130130/include/pkg-ab/h1d.hh
work-20130130/project.info
work-20130130/share/
work-20130130/share/hwaf/
work-20130130/share/hwaf/__hwaf_module__work.py
work-20130130/python/
work-20130130/python/__pycache__/
work-20130130/python/__pycache__/pkgaa.cpython-33.pyc
work-20130130/python/pkgaa.pyc
work-20130130/python/pkgaa.py
work-20130130/bin/
work-20130130/bin/pkg-ac
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
src/pkg-aa (git)
src/pkg-settings (git)
src/pkg-ac (git)
src/pkg-ab (git)

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

Let's say that our new package will use the shared library from
``pkg-aa``.
Modify the ``pkg_deps`` like so:

```python
def pkg_deps(ctx):
    ctx.use_pkg('pkg-aa')
    return
```

### configure
``configure`` is where one configures the package or project.
There, we can discover external libraries/binaries, load new build
tools/functions and/or define new environment variables.

Let's try to detect whether our system has ``CLHEP`` installed but
don't fail the build if it does not find it.

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
```

### build
``build`` is where one declares the build targets.

Let's create a simple shared library which uses ``CLHEP``
``LorentzVector``:

```sh
$ touch src/mytools/mypkg/src/mypkgtool.cxx
```

```c++
#include "CLHEP/Vector/LorentzVector.h"

extern "C" {
  
float
clhep_calc_mt(float x, float y, float z, float t) 
{
  return CLHEP::HepLorentzVector(x, y, z, t).mt();
}

}

// EOF
```

```sh
$ mkdir src/mytools/mypkg/python
$ touch src/mytools/mypkg/python/pyclhep.py
```

```python
import ctypes
lib = ctypes.cdll.LoadLibrary('libhello-clhep.so')
if not lib:
    raise RuntimeError("could not find hello-clhep")

calc_mt = lib.clhep_calc_mt
calc_mt.argtypes = [ctypes.c_float]*4
calc_mt.restype = ctypes.c_float

import sys
sys.stdout.write("hlv.mt(10,10,10,20) = %s\n" % calc_mt(10,10,10,20))
sys.stdout.flush()
# EOF #
```

and modify the ``build`` function like so:

```python
def build(ctx):
    ctx.build_linklib(
        name = 'hello-clhep',
        source = 'src/*.cxx',
        use = ['CLHEP'],
        )
    
    ctx(
        features     = 'py',
        name         = 'py-clhep',
        source       = 'python/pyclhep.py',
        install_path = '${INSTALL_AREA}/python',
        )

    return
```

Rebuild and run:
```sh
$ hwaf
[...]
$ hwaf run python -c 'import pyclhep'
hlv.mt(10,10,10,20) = 17.32050895690918
```

Note that we used the underlying features of ``waf`` to build and
install the python module.
This could be packaged up in a nice function instead, as was actually
done for the ``build_linklib`` function (which is defined and exported
in the ``pkg-settings`` package.)

### Queries

At the moment, a few queries have been implemented:

```sh
# list the parent project of the current project
$ hwaf show projects
project dependency list for [work] (#projs=0)
work
'show-projects' finished successfully (0.018s)

# list the dependencies of a given package
$ hwaf show pkg-uses mytools/mypkg
package dependency list for [mytools/mypkg] (#pkgs=1)
mytools/mypkg
  pkg-aa
'show-pkg-uses' finished successfully (0.018s)
```

