#install.packages("tuneR")
#install.packages("pastecs")
#install.packages("audio")

setwd("D:/emeli/Documents/Violin Classes/")

library(audio)
library(tuneR)
library(pastecs)

source("ProgressAnalysisFunctions.R")

tuneR::play(originalSound)

audiorec(6.3, filename)

### Wait running the script from here until after the restart! ###

testSound <- readWave(filename)
tuneR::play(testSound)

results <- transcribeMusic(testSound, expNotes = scaleNotes)

performance <- updatePerformance(results)

plotPerformance(performance)
#scoreAll(performance)
plotProgress(performance, by = "session")
plotProgress(performance[performance$expected_notenames != "g",], by = "session")
plotProgress(performance, by = "date")
plotProgress(performance[performance$expected_notenames != "g",], by = "date")
plotProgress(performance, by = "expected_notenames")
plotProgress(performance[performance$expected_notenames != "g",], by = "expected_notenames")
#View(performance)

