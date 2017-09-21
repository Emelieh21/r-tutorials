# Progression Analysis Functions

date = gsub(":","-",as.character(Sys.time()))

filename = paste0("recordings/",date,"_recording.wav")

originalSound <- readWave("G-scale.wav")

scaleNotesFreqs<- c(NA, NA, NA, 196.00, 196.00, NA, 220.0, NA, NA, 246.9, NA, 261.6, 261.6, NA, 293.7, 293.7, NA, 329.6, 329.6, NA, 370.0, 370.0, NA, 392.0, NA)
scaleNotes <- noteFromFF(scaleNotesFreqs)

expected_notes <- c(-14,-14,-14,-12,-12,-10,-10,-9,-9,-9,-7,-7,-7,-5,-5,-5,-3,-3,-3,-2,-2)
expected_notenames <- notenames(expected_notes)

# audio recording from https://stackoverflow.com/questions/22619561/audio-record-in-r
audiorec <- function(kk,f){  # kk: time length in seconds; f: filename
  if(f %in% list.files()) 
  {file.remove(f); print('The former file has been replaced');}
  require(audio)
  s11 <- rep(NA_real_, 16000*kk) # rate=16000
  message("5 seconds..")
  Sys.sleep(5)
  message("Recording starts now...")
  record(s11, 16000, 1)  # record in mono mode
  wait(kk)
  save.wave(s11,f)
  .rs.restartR()  
}

#http://www.vesnam.com/Rblog/transcribing-music-from-audio-files-2/

widthSample = 4096 
expNotes = NULL

transcribeMusic <- function(wavFile, widthSample = 4096, expNotes = NULL) {
  #See details about the wavFile, plot it, and/or play it
  #summary(wavFile)
  plot(wavFile)
  #tuneR::play(wavFile)
  
  perioWav <- periodogram(wavFile, width = widthSample)
  freqWav <- FF(perioWav)
  noteWav <- noteFromFF(freqWav) 
  
  melodyplot(perioWav, observed = noteWav, expected = expNotes, plotenergy = FALSE, main = Sys.Date())
  
  dev.copy(png, paste0("plots/plot_",date,".png"))
  dev.off()
  
  #Print out notes names
  noteWavNames <- noteWav[!is.na(noteWav)]
  noteWavNames <- noteWavNames[1:21]
  print(noteWavNames)
  print(notenames(noteWavNames))
  return(noteWavNames)
}

updatePerformance <- function(results){
  files <- list.files()
  if (("performance.csv" %in% files) == FALSE){
    message("No performance csv existing yet - creating it now...")
    dat <- as.data.frame(results)
    names(dat) <- "noteWavNames"
    dat$notenames <- notenames(results)
    dat$expected <- expected_notes
    dat$expected_notenames <- expected_notenames
    dat$date <- as.character(Sys.Date())
    dat$rownum <- row.names(dat)
    performance <- dat
    write.csv2(performance, "performance.csv", row.names = FALSE)
    print("Done!")
    return(performance)
  } else {
    performance <- read.csv2("performance.csv", stringsAsFactors = FALSE)
    dat <- as.data.frame(results)
    names(dat) <- "noteWavNames"
    dat$notenames <- notenames(results)
    dat$expected <- expected_notes
    dat$expected_notenames <- expected_notenames
    dat$date <- as.character(Sys.Date())
    dat$rownum <- row.names(dat)
    performance <- rbind(performance, dat)
    write.csv2(performance, "performance.csv", row.names = FALSE)
    print("Done!")
    return(performance)
  }
}

plotProgress <- function(performance){
  plot(performance$noteWavNames, type = "l", col = "red", main = "Progress (green = expected & red = you)")
  lines(performance$expected,col="green")
}


