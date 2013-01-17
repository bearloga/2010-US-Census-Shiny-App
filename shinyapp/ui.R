library(shiny)

library(UScensus2010)

data(states.names)
states <- as.list(states.names[-9])
names(states) <- datasets::state.name
states <- append(states,
				 list("Distict of Columbia"="district_of_columbia"),
				 after=8)
rm(states.names,envir=.GlobalEnv)

variables <- read.delim("variables.dat",stringsAsFactors=FALSE)
list_of_variables <- as.list(variables$Variable)
names(list_of_variables) <- variables$Name
rm(variables)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
	
	# Application title
	headerPanel("2010 US Census Shiny App"),
	
	sidebarPanel(
		
		selectInput("type","Choose map type:",
					choices = list("Counties in a State"='counties',
								   "Tracts in a State"='tractState',
								   "Tracts in a County"='tractCounty',
								   "Block Groups in a State"="blkgrpState",
								   "Block Groups in a County"="blkgrpCounty"),
# 								   "Block Groups in a Tract"="blkgrpTract",
# 								   "Blocks in a State"="blkState",
# 								   "Blocks in a County"="blkCounty"),
# 								   "Blocks in a Tract"="blkTract",
# 								   "Blocks in a Block Group"="blkBlockGroup"),
					multiple=F),
		helpText("'[Level] in State' types are computationally expensive."),
		
		# Colorblind friendly settings
		radioButtons("color","Type of heat colors:",
					 choices=list("Blue to Dark Orange"='bdo',
					 			 "Gray"='gray')),
		
		selectInput("state","Choose which state:",
					choices = states),
		helpText("Note: District of Columbia does not have counties."),
		
		conditionalPanel(
			condition="input.type == 'tractCounty' || input.type == 'blkgrpCounty'",
			uiOutput("countySelector")),
		
		numericInput("ncats","Number of bins/categories.",min=4,max=12,value=5),
		
		checkboxInput("usecustomcategories","Use custom bin/category labels.",FALSE),
		conditionalPanel(condition="input.usecustomcategories",
						 uiOutput("customcategories")),
		
		checkboxInput("autobreaks","Use automatic breaks.",TRUE),
		conditionalPanel(condition="input.autobreaks",
						 helpText("Breaks are generated with quantile function.")),
		
		selectInput("information","Choose which information to display.",
					choices=list_of_variables),
		
		h6("Coming soon: a bigger selection of which demographic variables.")
		
	),
		
	mainPanel(
		plotOutput("choropleth")
	)
))