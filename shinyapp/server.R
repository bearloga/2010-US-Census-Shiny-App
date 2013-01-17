library(shiny)
library(dichromat)
library(maps)
library(maptools)
gpclibPermit()
library(UScensus2010)
library(UScensus2010blk)
library(UScensus2010blkgrp)
library(UScensus2010cdp)
library(UScensus2010county)
library(UScensus2010tract)
data(countyfips)

source('choropleth2.R', echo=FALSE)

variables <- read.delim("variables.dat",stringsAsFactors=FALSE)
list_of_variables <- as.list(variables$Name)
names(list_of_variables) <- variables$Variable
rm(variables)

shinyServer(function(input, output) {
	
	chosenColor <- reactive(function(){
		input$color
	})
	chosenMapType <- reactive(function(){
		input$type
	})
	chosenState <- reactive(function(){
		input$state
	})
	numberOfCategories <- reactive(function(){
		input$ncats
	})
	
	# This will create a select list and populate it with
	# county names dependent on which state the user selected.
	output$countySelector <- reactiveUI(function(){
		counties <- countyfips[countyfips$statename==chosenState(),]
		counties.fips <- as.list(counties$fips)
		names(counties.fips) <- counties$countyname
		rm(counties)
		selectInput("county","Choose which county:",
					   choices=counties.fips)
	})
	chosenCounty <- reactive(function(){
		input$county
	})
	
	# This will allow the user to choose custom labels.
	usingCustomLabels <- reactive(function(){
		input$usecustomcategories
	})
	output$customcategories <- reactiveUI(function(){
		n <- numberOfCategories()
		temp <- list(n+1)
		temp[[1]] <- helpText("Smallest to largest.")
		for ( i in 1:n) {
			temp[[i+1]] <- textInput(inputId=paste("category",i,sep=""),
								   label="",
								   value=paste("Category",i))
		}
		temp
	})
	# Fetches the value of categoryi, i=1,...,input$ncats
	customCategories <- reactive(function(){
		n <- numberOfCategories()
		temp <- list(n)
		for ( i in 1:n) {
			temp[[i]] <- eval(parse(text=paste("input$category",i,sep="")))
		}
		# write(unlist(temp),file="C:/test.txt") # just for making sure it works
		temp
	})
	
	chosenVariable <- reactive(function(){
		input$information
	})
	
	output$choropleth <- reactivePlot(function() {
		
		## Minimizes function calls by storing the inputs values as static variables.
		N <- numberOfCategories()
		# cat(paste("Number of custom categories:",N,"\n"))
		chosen_map_type <- switch(chosenMapType(),
							  counties = list(level='county',reference='state'),
							  tractState = list(level='tract',reference='state'),
							  tractCounty = list(level='tract',reference='county'),
							  blkgrpState = list(level='blkgrp',reference='state'),
							  blkgrpCounty = list(level='blkgrp',reference='county'),
							  blkgrpTract = list(level='blkgrp',reference='tract'),
							  blkState = list(level='blk',reference='state'),
							  blkCounty = list(level='blk',reference='county'),
							  blkTract = list(level='blk',reference='tract'),
							  blkBlockGroup = list(level='blk',reference='blkgrp'))
		chosen_state <- chosenState()
		chosen_county <- chosenCounty()
		chosen_variable <- chosenVariable()
		
		# puts together the name of the dataset to be loaded.
		temp <- paste("",chosen_state,".",chosen_map_type$level,"10",sep="")
		
		# Loads the requested dataset.
		do.call(what="data",args=list(temp))
	
		# Optional:
		# if ( chosenColor() == 'gray' ) par(bg="light blue")
		
		# Density computation
		if ( chosen_variable == "P0010002" ) {
			# cat("Calculating the density... \n")
			eval(parse(text=paste("den10<-",temp,"$P0010001/areaPoly(",temp,")",sep="")))
			eval(parse(text=paste(temp,"$P0010002<-den10",sep="")))
		}
		
		# The following will subset the SPDFs appropriately (i.e. tracts in a specific county)
		# and then create the appropriate title to be used when plotting the choropleth.
		if ( (chosen_map_type$level=='tract' || chosen_map_type$level=='blk' || chosen_map_type$level=='blkgrp') && chosen_map_type$reference=="county" ) {
			
			# Constructs the subsetting code
			x <- paste("my.sp <- ",temp,"[",temp,"@data$county == '",substr(chosen_county,3,5),"',]",sep="")
			eval(parse(text=x)) # executes the subsetting code
			# Generates the appropriate title
			my.title <- paste(paste(chosen_map_type$level,"s",sep=""),"in",
							  countyfips[countyfips$fips==chosen_county,"countyname"],
							  "in",chosen_state)
		} else if ( chosen_map_type$level == "county" ) {
			my.sp <- eval(parse(text=temp))
			my.title <- paste("counties in",chosen_state)
		} else if ( (chosen_map_type$level=='tract' || chosen_map_type$level=='blk' || chosen_map_type$level=='blkgrp') && chosen_map_type$reference=="state" ) {
			my.sp <- eval(parse(text=temp))
			my.title <- paste(paste(chosen_map_type$level,"s",sep=""),"in",chosen_state)
		}
		
		# By separating the arguments into a list, we can add certain arguments
		# if conditions are satisfied. i.e. custom category labels
		choropleth.options <- list(
			
			# Spatial Polygons Data Frame
			sp = my.sp,
			
			# a character string
			# this must be the name of one of the
			# data.frame objects contained within
			# the SpatialPolygonsDataFrame
			# (e.g. "P0010001").
			dem = chosen_variable,
			
			# a list containing "quantile" and seq object from 0 to 1
			# ALTERNATIVELY: "manual" and a vector of N+1 break points
			# example: cuts=list("manual",1000*c(0,2,4,6,8,20))
			cuts=list("quantile",seq(0,1,length.out=N+1)),
			
			# a list containing a function
			# and list of arguments for the function
			# to produce the requested color scheme.
			color = list(fun = function(n){
				if ( chosenColor()=='bdo' ) {
					# from the dichromat package
					# 'Color schemes for dichromats'
					# by Thomas Lumley
					return(colorschemes$BluetoDarkOrange.12[floor(seq(1,12,length.out=n))])
				} else {
					return(gray(seq(1,0,length.out=n)))
				}
			},attr = list(N)),
			
			sub="Quantiles (Equal Frequency)",
			type="plot",
			
			# This needs to be fixed so that if the user selects
			# to look at a specific county within a state then
			# the title should include the county name.
			main=my.title,
			
			# The legend title will change to reflect what information
			# the user is looking at. 'Total Population' is default.
			legend=list(pos="bottomleft",title=list_of_variables[[chosen_variable]]),
			
			# If the user is colorblind and a gray scale is selected,
			# then borders are added to the grayscale polygons.
			border=ifelse(chosenColor()=='gray',"black","transparent")
			
		)
		# IF the user has specified that she/he wants to use custom labels,
		# this then provides those labels to the agrument, which is NULL by default.
		if ( usingCustomLabels() ) choropleth.options[['cat.labels']] <- customCategories()
		
		# Actually plot the data.
		do.call(what="choropleth2",args=choropleth.options)
		
		# The datasets may be quite heavy at times and must
		# be purged after the choropleth has been drawn.
		rm(list=temp,envir=.GlobalEnv)
	})
})