#! /bin/sh

ruby ./samplecode.rb > test.smt && z3 -smt2 test.smt
