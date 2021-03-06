Ypotryll
========

[![Build Status](https://travis-ci.org/jerith/ypotryll.svg?branch=master)](https://travis-ci.org/jerith/ypotryll)

OCaml AMQP client build on `lwt`.

This is a work in progress, and currently nowhere near ready to use.


Why?
----

I wanted a nice meaty problem to solve as a way of properly learning OCaml. I
originally started with the plan of writing a [Vumi][vumi] worker, but then I
discovered that the only OCaml AMQP client depends on [Ocamlnet][ocamlnet]
which doesn't install on my laptop.

I decided the world could use an AMQP library built on [lwt][lwt], so it was a
yak worth shaving on my way to OCaml Vumi goodness.


What?
-----

Things that have been implemented:

 * XML spec parser
 * Basic wire protocol frame decoder
 * Generated method frame parsers and builders
 * First pass at a high-level API (incomplete)

Things that still need to be implemented:

 * More high-level API
 * Everything else
 * More tests!

I'm actively working on this project, but I'm new to OCaml and I've never
written an AMQP client in any language, so I have no idea how long this will
take.


How?
----

Ypotryll uses an OASIS-generated makefile, so you can build it like so:
```
$ make configure
$ make
```

You can build and run the code generator as follows:
```
$ (cd code_gen; make configure; make)
$ code_gen/code_gen.byte < amqp0-9-1.xml
```


Thanks!
-------

I would like to thank the entire OCaml community for making this such a
pleasant experience, especially [Anil Madhavapeddy][avsm] for his excellent
interview on [Software Engineering Radio][seradio] that inspired me to look at
OCaml in the first place, the authors of [Real World OCaml][rwo] for a
fantastic tutorial and reference work, and the people in the #ocaml IRC channel
(Drup and whitequark in particular) for helping me turn my first fumbling
attempts into something that looks almost like real code.


[vumi]: https://github.com/praekelt/vumi
[ocamlnet]: http://projects.camlcity.org/projects/ocamlnet.html
[lwt]: http://ocsigen.org/lwt/
[avsm]: http://anil.recoil.org/
[seradio]: http://www.se-radio.net/2014/05/episode-204
[rwo]: https://realworldocaml.org/
