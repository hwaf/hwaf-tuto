hwaf-tuto
=========

``hwaf-tuto`` is a simple tutorial to show how to install ``hwaf`` and
use it.

## Installation

``hwaf`` is a ``Go`` binary produce by the [Go toolchain](http://golang.org).
So, if you have already the ``Go`` toolchain installed (see
[here](http://golang/install.html) for instructions) you just have to
do:

```sh
$ go get github.com/mana-fwk/git-tools/...
$ go get github.com/mana-fwk/hwaf
$ hwaf self init
```

to get the latest ``hwaf`` tool (and its ``git`` goodies) installed
and ready.


Packaged up binaries for ``hwaf`` are also available [here](http://cern.ch/mana-fwk/downloads/tar).
Untar under some directory like so:

```sh
$ mkdir local
$ cd local
$ curl -L \
  http://cern.ch/mana-fwk/downloads/tar/hwaf-20130129-linux-amd64.tar.gz \
  | tar zxf -
$ export HWAF_ROOT=`pwd`
$ export PATH=$HWAF_ROOT/bin:$PATH
```

## Getting started

The central tool in ``hwaf`` is the concept of the workarea, where
locally checked out packages will live.
To create such a place:

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

