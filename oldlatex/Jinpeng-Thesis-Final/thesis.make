#!/bin/bash

latex thesis.tex
latex thesis.tex
bibtex thesis.aux
latex thesis.tex
latex thesis.tex
dvipdf thesis.dvi
