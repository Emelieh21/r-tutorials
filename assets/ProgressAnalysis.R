#install.packages("tuneR")
#install.packages("audio")

setwd("SET WORKING DIRECTORY")

library(audio)
library(tuneR)

source("ProgressAnalysisFunctions.R") # The audiorec function in this script will look 
# for a folder named "recordings" in the working directory and the transcribeMusic function
# looks for a folder named "plots" to save the plots in.

tuneR::play(originalSound)

audiorec(6.3, filename)

### Wait running the script from here until after the restart! ###

testSound <- readWave(filename)
tuneR::play(testSound)

results <- transcribeMusic(testSound, expNotes = scaleNotes)

performance <- updatePerformance(results)

plotPerformance(performance)
plotProgress(performance, by = "session")
plotProgress(performance[performance$expected_notenames != "g",], by = "session")
plotProgress(performance, by = "date")
plotProgress(performance[performance$expected_notenames != "g",], by = "date")
plotProgress(performance, by = "expected_notenames")
plotProgress(performance[performance$expected_notenames != "g",], by = "expected_notenames")


