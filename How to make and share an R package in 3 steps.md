# How to make and share an R package in 3 steps 

If you find yourself often repeating the same scripts in R, you might come to the point where you want to turn them into reusable functions and create your own R package. This article explains how to create and share your own R package in 3 easy steps. 

I will explain how I made [my first package](https://github.com/Emelieh21/FlightsR) and which methods I found helpful. Of course, there are many approaches and there might be better or more efficient ones - but the following 3 steps worked for me and will guide you to having your own R package ready, installed and online in no time.

My first R package is a wrapper for the [FlightStats API](https://developer.flightstats.com/). You can sign up for FlightStats to get a free trial API key (which unfortunately works for one month only). However, you can of course make a wrapper for any API you like or make a non-API related package. Two links I found very useful for getting started making my first package are [this one](https://stat.ethz.ch/R-manual/R-devel/library/utils/html/package.skeleton.html) and [this one](http://blog.revolutionanalytics.com/2015/11/how-to-store-and-use-authentication-details-with-r.html) (regarding the storing of API keys). Also, I learned a lot using [this package](https://github.com/ropensci/gtfsr) as an example.

### 1. Prepare the functions you want to include

First of all, we need to have all the functions (and possibly dataframes & other objects) ready in our R environment. For example, imagine we want to include these two functions to store the API key and an app ID:

```R
setAPIKey <- function(){
  input = readline(prompt="Enter your FlightStats API Key: ")
  Sys.setenv(flightstats_api_key = input) # this is a more simple way of storing API keys, it saves it in the .Rprofile file, however this is only temporary - meaning next session the login details will have to be provided again. See below how to store login details in a more durable way.
  }
setAppId <- function(){
  input = readline(prompt="Enter your FlightStats appID: ")
  Sys.setenv(flightstats_app_id = input)
}
```

Now you can retrieve the login in details like this:

```R
ID = Sys.getenv("flightstats_app_id") # if the key does not exist, this returns an empty string (""), in this case the user should be prompted to use the setAPIKey() and setAppID() functions
KEY = Sys.getenv("flightstats_api_key") 
```

However, if you would like the login details to still be accessible the next time you open R, you can define your login details in the _.Renviron_ file (instead of the _.Rprofile_ file). The _.Renviron_ file can be found in your home directory. You can find the path to your home directory by running `Sys.getenv("HOME")`. For more info see [here](https://csgillespie.github.io/efficientR/r-startup.html). The final function to store the API key in the FlightsR package looked like [this](https://github.com/Emelieh21/FlightsR/blob/master/R/setAPIKey.R). 

By the way, it might be common knowledge, but I actually did not know it before and find it quite handy: If you want to know the script of any function in R, you can find it by just typing the function name and hit enter. For example:

```text
> read.csv
function (file, header = TRUE, sep = ",", quote = "\"", dec = ".", 
    fill = TRUE, comment.char = "", ...) 
read.table(file = file, header = header, sep = sep, quote = quote, 
    dec = dec, fill = fill, comment.char = comment.char, ...)
<bytecode: 0x029e046c>
<environment: namespace:utils>
```

Let's make another function that we can add to the package. Here is a simple function to list all airlines:

```R
listAirlines <- function(activeOnly=TRUE){
  ID = Sys.getenv("flightstats_app_id") 
  if (ID == ""){
    stop("Please set your FlightStats AppID and API Key with the setAPIKey() and setAppId() function. You can obtain these from https://developer.flightstats.com.")
  }
  KEY = Sys.getenv("flightstats_api_key")
  if (ID == ""){
    stop("Please set your FlightStats AppID and API Key with the setAPIKey() and setAppId() function. You can obtain these from https://developer.flightstats.com.")
  }  
  if(missing(activeOnly)){
    choice = "active"
  }
  if(activeOnly == FALSE) {
    choice = "all"
  } 
  else {
    choice = "active"
  }
  link = paste0("https://api.flightstats.com/flex/airlines/rest/v1/json/",choice,"?appId=",ID,"&appKey=",KEY)
  dat = getURL(link)
  dat_list <- fromJSON(dat)
  airlines <- dat_list$airlines
  return(airlines)
}
```

### 2: Use `package.skeleton()`, devtools & RoxyGen2 to let R prepare the necessary documents for you

```R
package.skeleton(name = "FlightR", list = c("listAirlines","listAirports","scheduledFlights","scheduledFlightsFullDay","searchAirline","searchAirport","setAPIKey","setAppId"))
```

That's it! Now in your working directory folder there should be a new folder with the name you just gave to your package. 

Now, what is handy from the function above is that it creates the folders and files you need in a new package folder ("FlightsR" in this case). In the `/R` folder you see now that every function you added has its own .R script and in the `/man` folder there is an .Rd file for each of the functions.

You can now go and manually change everything in these files that needs to be changed (documentation needs to be added, the import of external packages to be defined, etc.) - or use [roxygen2](https://github.com/klutometis/roxygen) and [devtools](https://cran.r-project.org/web/packages/devtools/index.html) to do it for you. Roxygen2 will complete the documentation in each .Rd file correctly and will create a _NAMESPACE_ file for you. To do this, make sure you **delete the current incomplete files** (this is, all the files in the `/man` folder and the _NAMESPACE_ file), otherwise you will get an error when you want to use devtools and roxygen2 later.

Now extra information needs to be added in the functions (for example, what are the **parameters** of the function, an **example** usage, necessary library **imports**, etc.), in the following way:

```R
#' Function searches a specific airline by IATA code
#'
#' @param value character, an airline IATA code
#' @return data.frame() with the airline
#'
#' @author Emelie Hofland, \email{emelie_hofland@hotmail.com}
#'
#' @examples
#' searchAirline("FR")
#'
#' @import RCurl
#' @import jsonlite
#' @export
#'
searchAirline <-
function(value){
  ID = Sys.getenv("flightstats_app_id")
  if (ID == ""){
    stop("Please set your FlightStats AppID and API Key with the setAPIKey() and setAppId() function. You can obtain these from https://developer.flightstats.com.")
  }
  KEY = Sys.getenv("flightstats_api_key")
  if (ID == ""){
    stop("Please set your FlightStats AppID and API Key with the setAPIKey() and setAppId() function. You can obtain these from https://developer.flightstats.com.")
  }
  link = paste0("https://api.flightstats.com/flex/airlines/rest/v1/json/iata/",toupper(value),"?appId=",ID,"&appKey=",KEY)
  dat <- getURL(link)
  dat_list <- fromJSON(dat)
  result <- dat_list$airlines
  if (length(result)==0){
    warning("Please make sure that you provide a valid airline IATA code.")
  }
  return(result)
}
```

Do not forget to add the **`@export`**, otherwise your functions will not be there when you open your library!

Now, when you have added this information for all your functions, make sure that devtools and roxygen2 are installed.

```R
install.packages("roxygen2")
install.packages("devtools")
```

And run the following commands in R:

```R
# to automatically generate the documentation:
document()

# to build the package
build()

# to install the package
install()
```

_Voila!_ You are done. I do not know if it is necessary, but just to be sure I restarted R at this point. In a new session you can now run `library(YourPackageName)` and this should work.

To adjust functions, you can just change things in the functions in the package and re-run the `document()`, `build()` and `install()` commands.

### 3: Pushing a custom made R package to GitHub (or GitLab)

**Note:** These steps assume that you have Git installed and configured on your PC.

1) Create a new repository in your github account.
2) Create and copy the https link to clone the repo on your PC.
3) Go to the folder on your PC where you want to save your repo, open the command line interface & type:
  `$ git clone https://github.com/YourGithub/YourPackage.git`
4) Copy all the files from your package in the folder and run:

```bash
 $ git add .
 $ git commit -m "whatever message you want to add"
 $ git push origin master
```

5) _Voila_ - now your package should be on GitHub!

Now people can download & install your package straight from GitHub or GitLab - the devtools library has a function for this:

```r
if (!require(devtools)) {
  install.packages('devtools')
}    
# If your repo is on GitHub
devtools::install_github('YourGithub/YourPackage')

# If your repo is public on GitLab:
devtools::install_git("https://gitlab/link/to/your/repo")

# If your repo is private on GitLab:
devtools::install_git("https://emelie.hofland:password@gitlab/link/to/your/repo.git")
```

