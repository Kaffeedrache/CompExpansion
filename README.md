# CompExpansion

Training set expansion of labeled comparisons with structural alignment.
Code for the paper (Kessler and Kuhn, 2015) - see below.


## Prerequisites
- [CompBase](https://github.com/WiltrudKessler/CompBase): 
    Basic data structures, in-/output and just general helpful stuff for my project.
- [SQLite](https://www.sqlite.org/), aka `sqlite-jdbc-3.7.2.jar`:
    Needed for caching for the vector space similarity measure in `de.uni_stuttgart.ims.expansion.similarity.VectorSpaceSimilarityCached`. If this is not found it falls back to a version without caching that may be a bit more slow, but it will work.



## Usage

This assumes that you have the basic stuff from `CompBase` compiled in a directory `../CompBase/bin` and the SQLite jar in the folder `lib` and you want to have the class files in `bin`.

Compile all the files:

    mkdir bin
    javac -cp src:bin/:../CompBase/bin:../lib/sqlite-jdbc-3.7.2.jar -d bin src/de/uni_stuttgart/ims/expansion/ExpandTrainingSet.java


Create a context vectors for the vector space similarity:
    
    

Open `runExpansion.sh`, adapt the paths to your files and run the script. It should look like this:

    JAVAPARAMS="-Xmx12G -cp bin/:../CompBase/bin:../lib/sqlite-jdbc-3.7.2.jar"
    ALLOPTS="-actype labeled,paths -simargs dep,position -simpreds 0 -aftype matrix -seltype comppos -n 30"
    SEEDS="data/seedsentences.parsed.txt"
    UNLABELED="data/unlabeledsentences.parsed.txt"
    OUTFOLDER="data/output/"
    LOGFILE="expansion.log"

    mkdir $OUTFOLDER
    java $JAVAPARAMS de.uni_stuttgart.ims.expansion.ExpandTrainingSet $ALLOPTS $SEEDS $UNLABELED $OUTFOLDER/expansion $LOGFILE


It is recommended to run the expansion on a machine with a lot of memory. The code is not optimized for speed, so if you run it on a large set of data it will take a while (depending on the similarities you chose and also on the number of argument candidates created).

In the end you will get two files for each predicate in each seed sentence where at least one expansion sentence is found. For the example data, you will get a file `data/output/expansion.1_7_higher.txt` which contains the labeled expansion sentences for predicate "higher", word number seven in the first sentence. The file `data/output/expansion.1_7_higher.scores` contains the alignments and the scores for the alignments for the same sentences.


## What does this actually do... ?

Basically, we have a small set of labeled seed sentences and a large set of unlabeled sentences. From the unlabeled sentences we want to select the ones most similar to a specific labeled seed sentence and project the labels onto them.

The annotations we want to project are comparisons. A comparison consists of a predicate and some arguments: the entities that are compared and an aspect they are compared in. For example in "A has a better resolution than B" the word "better" is the predicate, "A" and "B" are the entities and "resolution" is the aspect.

Say we have a seed sentence s with predicate p. Do the following for every unlabeled sentence u:
- if u does not contain p, discard the sentence 
- get all argument candidates from u and l
- score all possible alignments between the two candidate sets
- save best alignment and score

When we are done with all unlabeled sentences, sort all u by their alignment score and keep the n best sentences. Project the annotations from the labeled seed sentence s along the alignments and annotate the unlabeled sentences.

For more info read my paper listed below!


## Main classes and packages

Main class: `de.uni_stuttgart.ims.expansion.ExpandTrainingSet`

- `de.uni_stuttgart.ims.expansion.semisupervised`:
   Implementation of structural alignment in `SemiSupervisedExpansion`, uses everything else.
   
- `de.uni_stuttgart.ims.expansion.sentences`:
   Select a set of possible expansion sentences for a given seed sentence and predicate; 
   Identify the predicate candidates in the unlabeled sentence.
   Different methods are subclasses of `SentenceSelector`.

- `de.uni_stuttgart.ims.expansion.candidates`:
   Get the argument candidates from the sentences.
   Different methods are subclasses of `ArgumentCreator`.

- `de.uni_stuttgart.ims.expansion.similarity`:
   Compare two words and assign a similarity score;
   Give an overall similarity score for the whole alignment.
   Different methods are subclasses of `Similarity', combination of similarities use `ComposedSimilarity`.

- `de.uni_stuttgart.ims.expansion.alignment`:
   Do all alignments between candidates and chose the one with the highest similarity.
   Different methods are subclasses of `BestAlignmentFinder`.
   
- `de.uni_stuttgart.ims.expansion.lists`:
   Lists to sort found alignments by similarity scores.
   Different lists are subclasses of `BestScoreList`.




## Configurations for the RANLP paper

Setting "Path-Flat" :

    ALLOPTS="-actype labeled,paths -simargs vs,dep -simpreds 0 -aftype matrix -seltype comppos -n 30"
   
Setting "Dep-Flat" :

    ALLOPTS="-actype labeled,ancdesc -simargs vs,dep -simpreds 0 -aftype matrix -seltype comppos -n 30"

   
Setting "Path-Context" :

    ALLOPTS="-actype labeled,paths -simargs vs,window,dep,position,level,pathDeps -simpreds 0 -aftype matrix -seltype comppos -n 30"

   
Setting "Dep-Context" :

    ALLOPTS="-actype labeled,ancdesc -simargs vs,window,dep,position,level,pathDeps -simpreds 0 -aftype matrix -seltype comppos -n 30"



## Licence and References

(c) Wiltrud Kessler

This code is distributed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported license
[http://creativecommons.org/licenses/by-nc-sa/3.0/](http://creativecommons.org/licenses/by-nc-sa/3.0/)

Please cite:
Wiltrud Kessler and Jonas Kuhn (2015)
"Structural Alignment for Comparison Detection"
In Proceedings of the 10th Conference on Recent Advances in Natural Language Processing (RANLP 2015).


Copyright notice for `de.uni_stuttgart.ims.expansion.alignment.HungarianAlgorithm.java`:

> Copyright (c) 2012 Kevin L. Stern
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
