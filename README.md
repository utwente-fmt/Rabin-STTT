Explicit State Model Checking with Generalized Büchi and Rabin Automata
===

This repository hosts the experiments and results for the paper and provides a
short guide on how to install the tools and reproduce the results.

Please note that all experiments in the paper were performed on a machine 
running Ubuntu 14.04 with 4 AMD Opteron<sup>TM</sup> 6376 processors, 
each with 16 cores, forming a total of 64 cores. There is a total of 
512GB memory available. All experiments are explicitly set up to use 16
threads, consult `benchmark.sh` in the `beem-experiments` or `mcc-experiments`
subfolders for modifying this configuration. 

Submitted for a special issue in Springer's International Journal on Software
Tools for Technology Transfer (STTT), as an extended version of our [SPIN 2017
paper].

Authors:
---

* Formal Methods and Tools, University of Twente, The Netherlands
    - Vincent Bloemen*:      [<v.bloemen@utwente.nl>](mailto:v.bloemen@utwente.nl)
    - Jaco van de Pol:       [<j.c.vandepol@utwente.nl>](mailto:j.c.vandepol@utwente.nl)

* Laboratoire de Recherche et Développement de l'Epita, France
    - Alexandre Duret-Lutz:  [<adl@lrde.epita.fr>](mailto:adl@lrde.epita.fr)

\* Supported by the 3TU.BSR project.

Abstract
---

*In the automata theoretic approach to explicit state LTL model
checking, the synchronized product of the model and an automaton
that represents the negated formula is checked for emptiness.  In
practice, a (transition-based generalized) B\"uchi automaton (TGBA)
is used for this procedure.*

*This paper investigates whether using a more general form of
acceptance, namely transition-based generalized Rabin automata (TGRAs),
improves the model checking procedure.  TGRAs can have significantly fewer
states
than TGBAs, however the corresponding emptiness checking procedure is
more involved.  With recent advances in probabilistic model checking
and LTL to TGRA translators, it is only natural to ask whether
checking a TGRA directly is more advantageous in practice.*

*We designed a multi-core TGRA checking algorithm and performed
experiments on a subset of the models and formulas from the 2015
Model Checking Contest and generated LTL formulas for models from the BEEM
database. While we found little to no improvement by checking TGRAs
directly, we show how various aspects of a TGRA's structure influences the
model checking performance.*

*In this paper, we also introduce a Fin-less acceptance condition, which is a
disjunction of TGBAs. We show how to convert TGRA into automata with Fin-less
acceptance and show how a TGBA emptiness procedure can be extended to check
Fin-less automata.*

Installation
---

If you experience any issues with the installation please consult the [LTSmin] 
website and [Spot] website for further instructions.

Firstly for Ubuntu we need to install the following dependencies:

```
$ sudo apt-get install build-essential automake autoconf libtool libpopt-dev 
zlib1g-dev zlib1g flex ant asciidoc xmlto doxygen wget git
```

### Installing Spot 2.5.2

1. Download Spot:
    * `$ wget https://www.lrde.epita.fr/dload/spot/spot-2.5.2.tar.gz`
2. Unpack the tar:
    * `$ tar -xvf  spot-2.5.2.tar.gz`
2. Change directory:
    * `$ cd spot-2.5.2`
4. Configure:
    * `$ ./configure --prefix=$HOME/install --disable-python`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
5. Make and install:
    * `$ make && make install`


### Installing LTSmin

1. Clone the LTSmin repository:
    * `$ git clone git@github.com:utwente-fmt/ltsmin.git -b spin-sttt --recursive`
2. Change directory:
    * `$ cd ltsmin`
3. Run `ltsminreconf`:
    * `$ ./ltsminreconf`
4. Configure the LTSmin build:
    * `$ ./configure --prefix=$HOME/install --without-spot --disable-dist --disable-scoop`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
5. Make and install (we set a timeout during the compilation):
    * `$ make CFLAGS="-DCHECKER_TIMEOUT_TIME=600 -O2" && make install`


### Running the benchmarks

The scripts `beem-experiments/benchmark.sh` and `mcc-experiments/benchmark.sh`
are set up to perform all benchmark experiments on each configuration (see the
bottom of the scripts). Note that this script uses a timeout of 10 minutes for
each experiment. Also note that running both scripts will take several days to
complete, using the above-mentioned machine.

The `benchmark.sh` script provides information on the standard output regarding 
which experiment is currently being performed. Error messages, due to crashes
or timeouts are also provided on the standard output. Results are appended to 
the thee CSV files (one for each benchmark suite) in the `results` directory.

[LTSmin]: http://fmt.cs.utwente.nl/tools/ltsmin/
[SPIN 2017 paper]: https://research.utwente.nl/en/publications/explicit-state-model-checking-with-generalized-b%C3%BCchi-and-rabin-au
[Spot]: https://spot.lrde.epita.fr/


