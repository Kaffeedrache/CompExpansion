JAVAPARAMS="-Xmx12G -cp bin/:../CompBase/bin:../lib/sqlite-jdbc-3.7.2.jar"
ALLOPTS="-actype labeled,paths -simargs dep,position -simpreds 0 -aftype matrix -seltype comppos -n 30"
SEEDS="data/seedsentences.parsed.txt"
UNLABELED="data/unlabeledsentences.parsed.txt"
OUTFOLDER="data/output/"
LOGFILE="expansion.log"

mkdir $OUTFOLDER
java $JAVAPARAMS de.uni_stuttgart.ims.expansion.ExpandTrainingSet $ALLOPTS $SEEDS $UNLABELED $OUTFOLDER/expansion $LOGFILE
