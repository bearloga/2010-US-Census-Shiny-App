library(shiny)
# library(dichromat)
library(maps)
library(maptools)
gpclibPermit()
library(UScensus2010)
# library(UScensus2010blk)
# library(UScensus2010blkgrp)
# library(UScensus2010cdp)
library(UScensus2010county)
# library(UScensus2010tract)
# data(countyfips)

source('choropleth2.R', echo=FALSE)

data(pennsylvania.county10)

v1 <- pennsylvania.county10$P0010001
v2 <- areaPoly(pennsylvania.county10)

shinyServer(function(input, output) {
	output$plot <- renderPlot({
		pennsylvania.county10$New <- eval(parse(text=input$expression))
		
		choropleth.options <- list(
			
			# Spatial Polygons Data Frame
			sp = pennsylvania.county10,
			
			# a character string
			# this must be the name of one of the
			# data.frame objects contained within
			# the SpatialPolygonsDataFrame
			# (e.g. "P0010001").
			dem = "New",
			
			# a list containing "quantile" and seq object from 0 to 1
			# ALTERNATIVELY: "manual" and a vector of N+1 break points
			# example: cuts=list("manual",1000*c(0,2,4,6,8,20))
			cuts=list("quantile",seq(0,1,0.20)),
			
			# a list containing a function
			# and list of arguments for the function
			# to produce the requested color scheme.
			color = list(fun = function(n){
				gray(seq(1,0,length.out=n))
			},attr = list(5)),
			
			sub="Quantiles (Equal Frequency)",
			type="plot",
			
			# This needs to be fixed so that if the user selects
			# to look at a specific county within a state then
			# the title should include the county name.
			main=paste(input$name,"in Pennsylvania (at County level)"),
			
			# The legend title will change to reflect what information
			# the user is looking at. 'Total Population' is default.
			legend=list(pos="topright",title=input$name),
			
			# If the user is colorblind and a gray scale is selected,
			# then borders are added to the grayscale polygons.
			border="black"
			
		)
		
		do.call(what="choropleth2",args=choropleth.options)
		
# 		choropleth(pennsylvania.county10,dem="New")
# 		title(paste(input$name,"in Pennsylvania (at County level)"))
	})
	output$table <- renderTable({
		pennsylvania.county10$New <- eval(parse(text=input$expression))
		x <- data.frame(unname(pennsylvania.county10@data["NAME10"]),
						unname(pennsylvania.county10@data["New"]))
		colnames(x) <- c('Counties',input$name)
		rownames(x) <- 1:nrow(x)
		x
	})
})