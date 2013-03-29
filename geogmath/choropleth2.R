choropleth2 <- function (sp, dem = "P0010001",
						 
						 #######################
						 # for testing purposes
						 # 	data(california.county10)
						 # 	sp <- california.county10
						 # 	dem <- "P0010001"
						 #######################
						 
						 cuts = list("quantile", seq(0, 1, 0.20)),
						 # 	autocuts = TRUE,
						 # 	breaks = list(x=1000*c(0,2,4,6,8,20)),
						 cat.labels = NULL,
						 # 	color = list(fun = "hsv", attr = list(h = c(0.4, 0.5, 0.6, 0.7), s = 0.6, v = 0.6, alpha = 1)),
						 color = list(fun="gray",attr=list(level=seq(1,0,length.out=length(cuts[[2]])-1))),
						 main = NULL, 
						 sub = "Quantiles (equal frequency)",
						 legend = list(pos = "bottomleft", title = "Population Count"),
						 type = NULL, ...) {
	color.map <- function(x, dem, y = NULL) {
		# x <- sp; dem <- sp[[dem]]
		l.poly <- length(x@polygons)
		if ( cuts[[1]]=="manual" ) {
			dem.num <- cut(dem,breaks = cuts[[2]])
		} else {
			dem.num <- cut(dem, breaks = ceiling(do.call(cuts[[1]], list(x = dem, probs = cuts[[2]]))), dig.lab = 6)
		}
		dem.num[which(is.na(dem.num) == TRUE)] <- levels(dem.num)[1]
		l.uc <- length(table(dem.num))
		if (is.null(y)) {
			col.heat <- do.call(color$fun, color$attr)
		}
		else {
			col.heat <- y
		}
		dem.col <- cbind(col.heat, names(table(dem.num)))
		colors.dem <- vector(length = l.poly)
		for (i in 1:l.uc) {
			# 				cat(paste("dem.col[",i,", 2] = ",dem.col[i, 2],"\n",sep=""))
			colors.dem[which(dem.num == dem.col[i, 2])] <- dem.col[i, 1]
		}
		out <- list(colors = colors.dem, dem.cut = dem.col[, 2], table.colors = dem.col[, 1])
		out
	}
	colors.use <- color.map(sp, sp[[dem]])
	col <- colors.use$color
	#args <- list(x = sp, col = colors.use$color)
	args <- list(x = sp, ..., col = colors.use$color)
	do.call("plot", args)
	title(main)
# 	title(main = main, sub = sub)
# 	if ( !is.null(cat.labels) ) {
# 		legend(legend$pos, legend = cat.labels, fill = colors.use$table.colors, bty = "o", title = legend$title, bg = "white")
# 	} else {
# 		legend(legend$pos, legend = colors.use$dem.cut, fill = colors.use$table.colors, bty = "o", title = legend$title, bg = "white")
# 	}
}