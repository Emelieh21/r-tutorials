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
  for (i in c(5:1)){
    message(i)
    Sys.sleep(1)
  }
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
  plot(wavFile)
  
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
    dat$session <- 1
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
    session_id <- performance[nrow(performance),"session"] + 1
    dat$session <- session_id
    performance <- rbind(performance, dat)
    write.csv2(performance, "performance.csv", row.names = FALSE)
    print("Done!")
    right <- notenames(results)[notenames(results) %in% expected_notenames]
    print(paste0("Your score (% of correct notes): ",round(length(right)/length(results)*100,1),"%"))
    return(performance)
  }
}

plotPerformance <- function(performance){
  plot(performance$noteWavNames, type = "l", col = "red", main = "Performance (green = expected & red = you)")
  lines(performance$expected,col="green")
}

plotProgress <- function(performance, by){
  progress <- c()

  for (i in unique(performance[,by])){
    print(i)
    dat <- performance[performance[,by] == i,]
    dat$res <- dat$expected-dat$noteWavNames
    mse <- mean(dat$res^2)
    print(mse)
    progress <- c(progress,mse*-1)
  }
  
  plot(progress, type = "l", yaxt="n", xaxt="n",ylim = c(min(progress),0), lwd = 2, col = "tomato", xlab = by, ylab = "accuracy", main = paste0("G-Scale Accuracy (",unique(performance$date[performance$session == min(performance$session)])," - ", unique(performance$date[performance$session == max(performance$session)]),")"))
  axis(2, at = 0, labels="100%", las=2)
  axis(1, at = c(1:length(unique(performance[,by]))),labels = unique(performance[,by]))
}
