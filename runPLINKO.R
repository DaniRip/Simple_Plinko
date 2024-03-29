# This function runs a Naive plinko board simulator
# Default mode is a board that matches The Price is Right
# 9 categories, therefore, 10 columns
# 7 full rows (but 1 is the start)
# 6 partial (9 col) intermediate rows + actual rows

# Instructions for running:
#	1. Navigate to the folder with this function/file in it
#	2. Input: source("runPLINKO.R")
#	3. Input: runPLINKO()
# If this didn't work for you, then you just lost PLINKO! (jk, email me)

# Expected output:
# 	A datastructure with headings:
#	> chipStart (column #)
#	> chipEnd (column #)
#	> dropTimes (a made-up number from a normal distribution, 
#   demonstrating the continuous nature of the data generated 
#   by fall times in reality)

# Written by: Danielle A. Ripsman
# Contact at: daripsman@uwaterloo.ca
# Written for: MSCI 251: Probability and Statistics for Engineers 1
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# Copyright 2023, Danielle Ripsman

#This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or(at your option) any later version.

# This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

runPLINKO <- function(chipStart = 5, numCat = 9, numRows = 6){
	
  # Check inputs - lets not blow this up...

  if (numCat > 20){numCat = 20; print("limited to 20 categories")}
  if (numCat < 2){numCat = 2; print("corrected to 2 categories")}
  if (numRows > 20){numRows = 20; print("limited to 20 rows")}
  if (numRows < 1){numRows = 1; print("corrected to 1 row")}
  if (any(chipStart < 1) || any(chipStart > numCat)) {
    chipStart = 1; print("corrected to a legal placement", chipStart)
  }
    
  # make option for vector of position entry v.s. single position:
  if (length(chipStart)==1){
  	chipFinal = c(1:numCat)
  	chipFinal = table(chipFinal)
  	chipFinal = chipFinal-0.25  
  	barCol = "white"	
  }
          
  # The final row (before the bins) by definition has to exist:
  df = data.frame("col"=seq(0, numCat, 1),"row" = rep(1,numCat+1))
  
  # Create the by-row multiplication matrix
  pCur = diag(numCat)
  pMult = 0.5*diag(numCat) 
  diag(pMult[-numCat,-1]) = 0.25
  diag(pMult[-1,-numCat]) = 0.25
  pMult[2,1] = 0.5 # Fix the first row limitted prob issue
  pMult[numCat-1,numCat] = 0.5 # Fix the last row limitted prob issue
  
  for(i in 1:numRows){
  	# Long rows:
    dfb1 = data.frame("col"=seq(0.5, numCat-0.5,1),"row" = rep(i+0.5,numCat))
    # partial rows:
  	df1 = data.frame("col"=seq(0, numCat, 1),"row" = rep(i+1,numCat+1))
  	# Bind the rows to be handed off to points
  	df = rbind(df,dfb1,df1)
  	
    pCur = pMult%*%pCur
  }
    
  # Generate info for time calculations	
  PIRTimes = c(5.30, 5.62, 5.55, 5.51, 6.89)	
  #meanPIR = 5.774 #mean(PIRTimes)
  timeGenMean = .4*numRows/0.42 # My arbitrary meaning function!
  sdGen = sqrt(var(PIRTimes*numRows/6)) 
  dropTimes = rnorm(length(chipStart ), timeGenMean, sdGen)

  pCur = apply(pCur, 2, cumsum)
  
  chipEnd = c(1:length(chipStart))
  chipEndProbs = runif(length(chipStart))
  
  for(i in 1:length(chipStart)){
  	chipEnd[i] = min(which(chipEndProbs[i]<= pCur[,chipStart[i]]))
  }
  
  if(length(chipStart)>1){
	chipFinal = c(chipEnd, c(1:numCat))
	chipFinal = table(chipFinal)
	chipFinal = chipFinal-1
	chipFinal = chipFinal/sum(chipFinal)
  	barCol = "red"	
  }
  
  # Plotting!
  # Set up the plot area with bins, leaving space for a plinko board!
  barplot(chipFinal, ylim = c(0, numRows+3), space = 0, col = barCol)
  
  # Plot the PLINKO pegs (holy alliteration, batman!)
  points(df, pch = 16)   
  
  title("Simple PLINKO Game")
  
  # Now we can plot the side buffers:
  for(i in 1:numRows){
  	# Left side:
  	segments(0, i, 0.5, i+0.5, lwd = 2)
  	segments(0.5, i+0.5, 0  , i+1, lwd = 2)
  	# Right side:
  	segments(numCat, i, numCat-0.5, i+0.5, lwd = 2)
    segments(numCat-0.5, i+0.5, numCat, i+1, lwd = 2)
  }  

  if (length(chipStart)==1){
	  points(chipStart-0.5, numRows+1.5, pch = 16, col ="blue", cex = 3-0.1*max(0, numRows-6))
	  points(chipEnd-0.5, 0.35, pch = 16, col ="red", cex = 3-0.1*max(0, numRows-6))
  }
  
  return(data.frame(chipStart,chipEnd,dropTimes))
  
}


