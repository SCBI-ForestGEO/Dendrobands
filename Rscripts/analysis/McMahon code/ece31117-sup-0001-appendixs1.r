### R code from vignette source 'MODEL_FIT_NEW_revised.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: Roptions
###################################################
library(MASS)


###################################################
### code chunk number 2: lg5.functions
###################################################
# This function predicts a diameter given the day of the year and a vector of parameters for the lg5 model.
# It is called by the lg5.ss and lg5.plot functions.

lg5.pred <- function(params, doy) {
	L <- params[1] # min(dbh, na.rm = T)
	K <- params[2]
	doy.ip <- params[3]
	r <- params[4]
	theta <- params[5]
	dbh <- vector(length = length(doy))
	dbh <- L + ((K - L) / (1 + 1/theta * exp(-(r * (doy - doy.ip) / theta)) ^ theta))
	return(dbh)
}

lg5.ML <- function(params, doy, dbh, resid.sd) {
	pred.dbh <- lg5.pred(params, doy)
	pred.ML <-  -sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
	return(pred.ML)
}

lg5.ML.wt <- function(params, doy, dbh, resid.sd) { 
	wts <- 1 / dnorm(abs(seq(-2, 2, length = length(doy))), 0, 1)
	pred.dbh <- lg5.pred(params, doy)
	pred.ML <- -sum((wts * dnorm(dbh, pred.dbh, resid.sd, log = T)))
	return(pred.ML)
}

get.doy <- function(x) {
	names.data <- names(x)
	doy.1 <- as.numeric(unlist(strsplit(names.data[grep("X", names.data)], "X")))
	doy <- doy.1[!is.na(doy.1)]
	return(doy)
}

get.lg5.resids <- function(params, doy, dbh) { 
	lg5.resid <- dbh - lg5.pred(params, doy)
	return(lg5.resid)
}



###################################################
### code chunk number 3: upper.lower.functions
###################################################
# LOWER AND UPPER ASYMPTOTES

pred.doy <- function(params, a, diam.given = 0) {
	params <- as.numeric(params)
	L <- params[1] # min(dbh, na.rm = T)
	K <- params[2]
	doy.ip <- params[3]
	r <- params[4]
	theta <- params[5]
	a.par <- a
	.expr1 <- (K - L) / (a.par - L) 
	.expr2 <- doy.ip * r - theta * log(((.expr1 - 1) * theta) ^ (1/theta))
	.expr3 <- .expr2 / r
	dcrit <- .expr3 
	
	return(dcrit)
} 

lg5.pred.a <- function (a, params, doy, dbh, asymptote = "lower") {
	asymptote <- ifelse(length(a) > 1, "both", asymptote)
	L <- params[1] # min(dbh, na.rm = T)
	K <- params[2]
	doy.ip <- params[3]
	r <- params[4]
	theta <- params[5]
	diam <- vector(length = length(doy))
	if(asymptote == "lower") {
		d.crit <- pred.doy(params, a)
		diam[which(doy <= d.crit)] <- a
		diam[which(doy > d.crit)] <- L + ((K - L) / (1 + 1/theta * exp(-(r * (doy[which(doy > d.crit)] - doy.ip) / theta)) ^ theta))
	}else{ 
		if(asymptote == "upper") {
			d.crit <- pred.doy(params, a)
			diam[which(doy >= d.crit)] <- a
			diam[which(doy < d.crit)] <- L + ((K - L) / (1 + 1/theta * exp(-(r * (doy[which(doy < d.crit)] - doy.ip) / theta)) ^ theta))
		}else{
			if(asymptote == "both") {
				d.crit <- pred.doy(params, a)
				diam[which(doy <= d.crit[1])] <- a[1]
				diam[which(doy >= d.crit[2])] <- a[2]
				diam[which(doy > d.crit[1] & doy < d.crit[2])] <- L + ((K - L) / (1 + 1/theta * exp(-(r * (doy[which(doy > d.crit[1] & doy < d.crit[2])] - doy.ip) / theta)) ^ theta))
			}
		}
	}	
	return(diam)
}

lg5.ML.a <- function(a, params, doy, dbh, resid.sd) {
	pred.dbh <- lg5.pred.a(a, params, doy)
	pred.ML <- -sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
}

make.seq <- function(param, params, deviation = 0.1, len.seq = 50, CI = c(0, 0), asymptote = "lower", min.val = NULL, max.val = NULL) {
	if(asymptote == "lower") {
		if(CI[1] > 0) {
			lower.lim <- max(min.val, CI[1] * (1 - deviation), na.rm = T)
			par.seq <- seq(lower.lim, (CI[2] * (1 + deviation)), length = len.seq)
		}else{
			par.seq <- seq(min.val, (param + deviation * param), length = len.seq)
			
		}
	}else{
		if(CI[1] > 0) {
			upper.lim <- min(max.val, CI[2] * (1 + deviation), na.rm = T)
			par.seq <- seq((CI[1] * (1 - deviation)), upper.lim, length = len.seq)
		}else{
			par.seq <- seq((param - deviation * param), max.val, length = len.seq)
		}
	}
	return(par.seq)
}

start.diam <- function(params, seq.l, doy, dbh, deviation.val, figure = FALSE, resid.sd = 0.1) {
	
	complete <- complete.cases(doy, dbh)
	doy <- doy[complete]
	dbh <- dbh[complete]
	
	profile.like.vec <- vector(length = seq.l)
	pred.min <- lg5.pred(params, doy[1])
	min.val <- max(min(dbh), pred.min, min(params[1], params[2]))
	
	param.vec.tmp <- make.seq(param = min(dbh, na.rm = T), params, deviation = deviation.val, len.seq = seq.l, asymptote = "lower", min.val = min.val)
	for(p in 1:seq.l) {
		pred.dbh <- lg5.pred.a(a = param.vec.tmp[p], params, doy)
		profile.like.vec[p] <- sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
	}
	xi.val <- max(profile.like.vec) - 1.92
	max.value <- param.vec.tmp[which(profile.like.vec == max(profile.like.vec))]
	values.above <- which(profile.like.vec > xi.val)
	ci.lower <- param.vec.tmp[min(values.above)]
	ci.upper <- param.vec.tmp[max(values.above)]
	ci.params <- c(ci.lower, ci.upper)
	
	param.vec.tmp <- make.seq(param = max.value, params, deviation = 0.0001, len.seq = seq.l, CI = ci.params, asymptote = "lower", min.val = min.val)
	for(p in 1:seq.l) {
		pred.dbh <- lg5.pred.a(a = param.vec.tmp[p], params, doy)
		profile.like.vec[p] <- sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
	}
	xi.val <- max(profile.like.vec) - 1.92
	max.value <- param.vec.tmp[which(profile.like.vec == max(profile.like.vec))]
	values.above <- which(profile.like.vec > xi.val)
	ci.lower <- param.vec.tmp[min(values.above)]
	ci.upper <- param.vec.tmp[max(values.above)]
	ci.params <- c(ci.lower, ci.upper)
	if(figure) {
		plot(param.vec.tmp, profile.like.vec, type = "l", xlab = "Parameter value", ylab = "Likelihood")
		abline(h = xi.val, col = "darkred")
		abline(v = c(ci.lower, ci.upper), col = "darkblue", lty = 2)
	}	
	
	start.values <- c(max.value, ci.lower, ci.upper, max(profile.like.vec, na.rm = TRUE))
	return(start.values)
}

end.diam <- function(seq.l, params, doy, dbh, deviation.val, figure = FALSE, resid.sd = 0.1) {
	
	complete <- complete.cases(doy, dbh)
	doy <- doy[complete]
	dbh <- dbh[complete]
	
	profile.like.vec <- vector(length = seq.l)
	
	pred.max <- lg5.pred(params, doy[length(doy)])
	max.val <- min(max(dbh), pred.max, max(params[1], params[2]))
	
	param.vec.tmp <- make.seq(param = max(dbh, na.rm = T), params, deviation = deviation.val, len.seq = seq.l, asymptote = "upper", max.val = max.val)
	
	for(p in 1:seq.l) {
		pred.dbh <- lg5.pred.a(a = param.vec.tmp[p], params = params, doy, asymptote = "upper")
		profile.like.vec[p] <- sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
	}
	
	xi.val <- max(profile.like.vec) - 1.92
	max.value <- param.vec.tmp[which(profile.like.vec == max(profile.like.vec))]
	values.above <- which(profile.like.vec > xi.val)
	ci.lower <- param.vec.tmp[min(values.above)]
	ci.upper <- param.vec.tmp[max(values.above)]
	ci.params <- c(ci.lower, ci.upper)
	
	param.vec.tmp <- make.seq(param = max.value, params, deviation = 0.0001, len.seq = seq.l, CI = ci.params, asymptote = "upper", max.val = max.val)
	
	for(p in 1:seq.l) {
		pred.dbh <- lg5.pred.a(a = param.vec.tmp[p], params = params, doy, asymptote = "upper")
		profile.like.vec[p] <- sum(dnorm(dbh, pred.dbh, resid.sd, log = T))
	}
	
	values.above <- which(profile.like.vec > xi.val)
	ci.lower <- param.vec.tmp[min(values.above)]
	ci.upper <- param.vec.tmp[max(values.above)]
	ci.params <- c(ci.lower, ci.upper)
	max.value <- param.vec.tmp[which(profile.like.vec == max(profile.like.vec))]
	
	if(figure) {
		plot(param.vec.tmp, profile.like.vec, type = "l", xlab = "Parameter value", ylab = "Likelihood")
		xi.val <- max(profile.like.vec) - 1.92
		abline(h = xi.val, col = "darkred")
		abline(v = c(ci.lower, ci.upper), col = "darkblue", lty = 2)
	}
	
	end.values <- c(max.value, ci.lower, ci.upper, max(profile.like.vec, na.rm = TRUE))
	return(end.values)
}



###################################################
### code chunk number 5: data
###################################################
doy.1 <- c(112, 120, 124, 130, 134, 139, 
144, 148, 153, 158, 165, 172, 179, 187, 190, 193, 200, 207, 214, 217, 221,
225, 228, 232, 237, 244, 251, 256, 263, 270, 285, 291, 301) 
dbh.1 <- c(18.99449, 18.99512, 19.00085, 19.01008, 19.03077, 19.06038, 19.07406,
19.08584, 19.12659, 19.17465, 19.19821, 19.24150, 19.27619, 19.30579,
19.30898, 19.34113, 19.37105, 19.38919, 19.39365, 19.41243, 19.41911,
19.43471, 19.43726, 19.44076, 19.44553, 19.44458, 19.44521, 19.44903,
19.44872, 19.45254, 19.45731, 19.45890, 19.45890)


###################################################
### code chunk number 9: lg5.model.runs
###################################################

# The list/unlist is done so that we can see the values attributed to the
# parameters and then make them numeric so that the optim function can use them
# as a numeric vector.


##  STARTING PARAMETERS AND MIN AND MAX VALUES FOR THE L-BFGS-B CALLS

dbh.data <- read.csv(file = "Forest_data.csv", header = T)
tree.no <- dim(dbh.data)[1]
doy.full <- get.doy(dbh.data)
lg5.hess <- vector("list", tree.no)
winning.optim.call <- c()
optim.output.df <- c()
resids.mat <- matrix(NA, tree.no, length(doy.full))
pdf("FIGURES/lg5_fit_all.pdf")
par(mfrow = c(2,2))
pb <- txtProgressBar(style = 3)
for(i in 1:tree.no) {
  setTxtProgressBar(pb, i / tree.no, title = NULL, label = NULL)
	par(mfrow = c(1,1))
#	pdf(file = sprintf("FIGURES/lg5_fit_%i.pdf", i))
	dbh <- as.numeric(dbh.data[i,])
	
	complete <- complete.cases(dbh)
	dbh <- dbh[complete]
	doy <- doy.full[complete]
	doy.ip.hat <- doy[(which(dbh > mean(dbh)))[1]]
	par.list <- list(L = min(dbh, na.rm = TRUE), K = max(dbh, na.rm = TRUE), doy.ip = doy.ip.hat, r = .08, theta = 1)
	params <- as.numeric(unlist(par.list))
	params.start <- params
	optim.min <- c((min(dbh, na.rm = TRUE) * 0.99), quantile(dbh, 0.5, na.rm = TRUE), 0, 0, 0.01)
	
	optim.max <- c(min(dbh, na.rm = TRUE), max(dbh, na.rm = TRUE), 350, 0.1, 15)
	resid.sd <- 0.1
	hess.tmp <- vector("list", 6)
	##  THESE ARE THE CALLS TO OPTIM  ##
  # weigted values have false ML estimates, so the estimate is re-assessed based on the optimized parameters in an unweighted call
	
  lg5.output.LB <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML, method = "L-BFGS-B", lower = optim.min, upper = optim.max, hessian = TRUE, control = list(trace = 0))
	hess.tmp[[1]] <- lg5.output.LB$hessian
	params <- lg5.output.LB$par
	
	lg5.output.LB.wt <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML.wt, method = "L-BFGS-B", lower = optim.min, upper = optim.max, hessian = TRUE, control = list(trace = 0))
	lg5.output.LB.wt$value <- lg5.ML(params = lg5.output.LB.wt$par, doy, dbh, resid.sd = resid.sd)
	hess.tmp[[2]] <- lg5.output.LB.wt$hessian
	
  lg5.output.NM <- optim(par = params, fn = lg5.ML, resid.sd = resid.sd,  method = "Nelder-Mead", hessian = TRUE, control = list(trace = 0), doy = doy, dbh = dbh)
	hess.tmp[[3]] <- lg5.output.NM$hessian
	
	lg5.output.NM.wt <- optim(par = params, fn = lg5.ML.wt, resid.sd = resid.sd,  method = "Nelder-Mead", hessian = TRUE, control = list(trace = 0), doy = doy, dbh = dbh)
	lg5.output.NM.wt$value <- lg5.ML(lg5.output.NM.wt$par, doy, dbh, resid.sd = resid.sd)
	hess.tmp[[4]] <- lg5.output.NM.wt$hessian
	
	lg5.output.SANN <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML, method = "SANN",  hessian = TRUE, control = list(maxit = 30000, trace = F))
	hess.tmp[[5]] <- lg5.output.SANN$hessian
	
	lg5.output.SANN.wt <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML.wt, method = "SANN",  hessian = TRUE, control = list(maxit = 30000, trace = F))
	hess.tmp[[6]] <- lg5.output.SANN.wt$hessian
	
	lg5.output.SANN.wt$value <- lg5.ML(lg5.output.SANN.wt$par, doy, dbh, resid.sd = resid.sd)
	
	
	## CONSOLIDATE THE RESULTS  ##
	
	optim.output <- rbind(c(params.start, NA), c(lg5.output.LB$par, lg5.output.LB$value), c(lg5.output.LB.wt$par, lg5.output.LB.wt$value), c(lg5.output.NM$par, lg5.output.NM$value), c(lg5.output.NM.wt$par, lg5.output.NM.wt$value), c(lg5.output.SANN$par, lg5.output.SANN$value), c(lg5.output.SANN.wt$par, lg5.output.SANN.wt$value))
	
	winner <- rep(".", length = 7)
	winner[1] <- NA
	winner[which(optim.output[,6] == min(optim.output[-1,6], na.rm = T))] <- "*"
	
	calls <- c("Starting", "L-BFGS-B", "L-BFGS-B wt", "N-M", "N-M wt", "SANN", "SANN wt")
	
	##  MAKE A DATAFRAME OF THE RESULTS  ##
	optim.output.tmp <- round(optim.output, digits = 4)
	optim.output.df <- as.data.frame(rbind(optim.output.df, cbind(i, calls, optim.output.tmp, winner)))
	
	
	#############################
	lg5.hess[[i]] <- hess.tmp[which(winner == "*")]
	winner <- match(min(optim.output[-1, 6], na.rm = T), optim.output[-1, 6])

	win.vec <- rep(2, 6)
	win.vec[winner] <- 1
	cols <- brewer.pal(dim(optim.output)[1], name = "Dark2")
	if(i == 1) {
		optim.output1 <- optim.output
		
		win.vec1 <- win.vec
		optim.output.df.1 <- optim.output.df[, -1]
		names(optim.output.df.1) <- c("Optim.call", "L", "K", "doy_ip", "r", "theta", "ML", "Best.ML") 
		doy1 <- doy
		dbh1 <- dbh
	}
	plot(doy, dbh, xlab = "Day of the year", ylab = "DBH (cm)", pch = 19, col = "gray15", main = sprintf("Annual Growth for tree %i", i), cex = 1)
	
	days <- seq(365)
	for(j in 2:dim(optim.output)[1]) {
		lines(days, lg5.pred(params = optim.output[j ,], doy = days), col = cols[j - 1], lty = win.vec[j - 1], lwd = 1)
	}
	
	legend("bottomright", legend = calls[-1], col = cols, lwd = 2, lty = win.vec)
	
	
#	dev.off()	
	winning.optim.call[i] <- c("L-BFGS-B", "L-BFGS-B wt", "N-M", "N-M wt", "SANN", "SANN wt")[winner]
	resids.mat[i, complete] <- get.lg5.resids(params = lg5.output.LB.wt$par, doy, dbh)
}
close(pb)
dev.off()

	names(optim.output.df) <- c("Tree.no", "Optim.call", "L", "K", "doy_ip", "r", "theta", "ML", "Best.ML") 
write.csv(optim.output.df, file = "Optim_output.csv", quote = FALSE, row.names = FALSE)


winner.tab <- table(winning.optim.call)
	


###################################################
### code chunk number 10: upper.lower.bounds
###################################################

# The list/unlist is done so that we can see the values attributed to the
# parameters and then make them numeric so that the optim function can use them
# as a numeric vector.

dbh.data <- read.csv(file = "Forest_data.csv", header = T)
tree.no <- dim(dbh.data)[1]
doy.full <- get.doy(dbh.data)
Param.df <- as.data.frame(array(dim = c(tree.no, 7)))

deviation.val <- c(0.01)
seq.l <- 200

start.d <- matrix(NA, tree.no, 4)
end.d <- matrix(NA, tree.no, 4)


pdf("FIGURES/HI_LO_fit_all.pdf")
par(mfrow = c(2,2))

for(i in 1:tree.no) {
	print(i)
	
#	par(mfrow = c(1,1))
#	pdf(file = sprintf("FIGURES/Low_up_%i.pdf", i))
	
	dbh <- as.numeric(dbh.data[i,])
	
	complete <- complete.cases(dbh)
	dbh <- dbh[complete]
	doy <- doy.full[complete]
	doy.ip.hat <- doy[(which(dbh > mean(dbh)))[1]]
	par.list <- list(L = min(dbh, na.rm = TRUE), K = max(dbh, na.rm = TRUE), doy.ip = doy.ip.hat, r = 0.08, theta = 1)
	params <- as.numeric(unlist(par.list))
	
	optim.min <- c((min(dbh, na.rm = TRUE) * 0.99), quantile(dbh, 0.5, na.rm = TRUE), 0, 0, 0.01)
	
	optim.max <- c(min(dbh, na.rm = TRUE), max(dbh, na.rm = TRUE), 350, 0.1, 15)
	resid.sd <- 0.1

	##  THESE ARE THE CALLS TO OPTIM  ##

	
	lg5.output.LB <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML, method = "L-BFGS-B", lower = optim.min, upper = optim.max, hessian = TRUE, control = list(trace = 0))
	params <- lg5.output.LB$par
	
	win.optim.call <- winning.optim.call[i]
	if(win.optim.call == "L-BFGS-B wt") {
		hi.lo.output <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML.wt, method = "L-BFGS-B", hessian = TRUE, control = list(trace = 0))
	}else{	
		hi.lo.output <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML.wt, method = "Nelder-Mead", hessian = TRUE, control = list(trace = 0))
	}

	params.tmp <- hi.lo.output$par
	## Now call the boundary functions
	
	start.d[i ,] <- start.diam(params = params.tmp, seq.l = seq.l,  doy = doy, dbh, deviation.val = deviation.val, figure = FALSE, resid.sd)
	
	end.d[i, ] <- end.diam(params = params.tmp, seq.l, doy, dbh, deviation.val, figure = FALSE, resid.sd)  #fix this ... dev.val too small
	
	a <- c(start.d[i, 1], end.d[i, 1])
	
	plot(doy, dbh, xlab = "Day of the year", ylab = "DBH (cm)", pch = 19, col = "gray15", main = sprintf("Annual Growth for tree %i", i), cex = 1)
	lines(days, lg5.pred.a(a, params = params.tmp, doy = days, asymptote = "both"), col = "darkred", lty = 1, lwd = 1)
	Param.df[i, 6:7] <- a
	
	Param.df[i, 1:5] <- params.tmp
	
#	dev.off()
}

dev.off()


names(Param.df) <- c("L", "K", "doy_ip", "r", "theta", "a", "b")
write.csv(Param.df, file = "SERC_hi_lo_lg5.csv", quote = FALSE, row.names = FALSE)

	


###################################################
### code chunk number 11: sparse.data
###################################################
	samp.output <- list()
	ct <- 0
	for(i in (length(doy) - 9):1) {
		ct <- ct + 1
		doy.samp <- c(floor(seq(1, 33, length.out = 34 - i)))
		doy <- doy1[doy.samp]
		dbh <- dbh1[doy.samp]
		
		doy.ip.hat <- doy[(which(dbh > mean(dbh)))[1]]
		par.list <- list(L = min(dbh, na.rm = TRUE), K = max(dbh, na.rm = TRUE), doy.ip = doy.ip.hat, r = 0.08, theta = 1)
		params <- as.numeric(unlist(par.list))
		
		optim.min <- c((min(dbh, na.rm = TRUE) * 0.99), quantile(dbh, 0.5, na.rm = TRUE), 0, 0, 0.01)
		
		optim.max <- c(min(dbh, na.rm = TRUE), max(dbh, na.rm = TRUE), 350, 0.1, 15)
		resid.sd <- 0.1
		
		##  THESE ARE THE CALLS TO OPTIM  ##
		
		
		lg5.output.LB <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML, method = "L-BFGS-B", hessian = TRUE, control = list(trace = 0))
		params <- lg5.output.LB$par
		
		samp.output[[ct]] <- optim(par = params, doy = doy, dbh = dbh, resid.sd = resid.sd, fn = lg5.ML, method = "Nelder-Mead", hessian = TRUE, control = list(trace = 0))
		samp.output[[ct]]$n <- length(doy)
	}
	samp.n <- c()
	result.samp <- vector("list", 5)
	for(rs in 1:5) {
		result.samp[[rs]]$par <- matrix(NA, 4, length(samp.output))
	}	
	for(so in 1:length(samp.output)) {
		var.tmp <- 2 * sqrt(diag(ginv(samp.output[[so]]$hessian)))
		par.tmp <- samp.output[[so]]$par
		samp.n <- samp.output[[so]]$n
		for(p in 1:length(par.tmp)) {
			result.samp[[p]]$par[, so] <- rbind(par.tmp[p], (par.tmp[p] - var.tmp[p]), (par.tmp[p] + var.tmp[p]), samp.n)
			
		}
	}


###################################################
### code chunk number 12: extensions
###################################################
# Extended functions for inference


# This function predicts a diameter given the day of the year and a vector of parameters for the lg5 model.
# It is called by the lg5.ss and lg5.plot functions.
		
lg5.CH <- function(paras, doyCP, dbhCP) {
	pred.dbh <- lg5.pred(paras, doyCP)
	pred.ND <-  sum(pred.dbh - dbhCP) # for "Negative Difference"
	return(pred.ND)
}

get.CH.resid <- function(rate, params, doy, dbh, log.rate = FALSE) { 
	lg5.pred <- lg5.pred(params, doy)
	rates <- lg5.deriv(params, doy)
	if(log.rate) {
		resids <- lg5.pred - dbh * log(rates + 0.000001)
	}else{
		resids <- lg5.pred - dbh * rates
	}
	return(resids)
}

# This function takes the numerical derivative. 
#	Default values return a single day of growth.
#	Using the 'growth' argument, the derivative 
#		can be returned, scaled by annual growth.
lg5.deriv <- function(paras, doy, growth = 1, shift = 0.5) {
  paras = as.numeric(paras)
	.loVal <- lg5.pred(paras, (doy - shift))
	.hiVal <- lg5.pred(paras, (doy + shift))
	deriv.lg5 <- (.hiVal - .loVal) / (2 * shift)
	return(deriv.lg5 / growth)
}	

max.growth.day <- function(paras) {
	days <- seq(365)
	.deriv <- lg5.deriv(paras, days)
	fastest.day <- max(days[which( .deriv == max(.deriv))], start.day, na.rm = TRUE)
	return(fastest.day)
}

max.growth.rate <- function(paras) {
	days <- seq(round(pred.doy(params, params$a)), 365)
	.deriv <- lg5.deriv(paras, days)
	growth.rate <- max(.deriv, na.rm = TRUE)
	return(growth.rate)
}

outer.hull <- function(params, doy, dbh, quant = 0.8) {
  a <- params$a
	b <- params$b
	paras <- as.numeric(params[1:5])
	curve.pure <- (which(doy > pred.doy(paras, a) & doy < pred.doy(paras, b)))
#	curve.pure <- (which(doy > pred.doy(paras, a)))
	doyP <- c(pred.doy(paras, a), doy[curve.pure], pred.doy(paras, b))
	dbhP <- c(a, dbh[curve.pure], b)
	residsP <- get.lg5.resids(params = paras, doy = doyP, dbh = dbhP)
	ln.data <- length(residsP)	
	top.resids <- unique(c(1, which(residsP >= quantile(residsP, quant)), length(residsP)))
	doyP2 <- doyP[top.resids]
	dbhP2 <- dbhP[top.resids]
	SSstart <- function(doy = doyP2, dbh = dbhP2) {
		lm.fit <- lm(dbhP2 ~ doyP2 + I(doyP2^2))
		new.doy <- seq(range(doyP2)[1], range(doyP2)[2])
		new.dbh <- predict(lm.fit, newdata = data.frame(doyP2 = new.doy), type = c("response"))
	}
	optim.min <- c((min(dbhP2, na.rm = TRUE) * 0.99), quantile(dbhP2, 0.5, na.rm = TRUE), 0, 0, 0.01)
	
	optim.max <- c(min(dbhP2, na.rm = TRUE), max(dbhP2, na.rm = TRUE), 350, 0.1, 15)

	OH.fit <- optim(par = paras, fn = lg5.ML, resid.sd = resid.sd,  method = "L-BFGS-B", lower = optim.min, upper = optim.max, hessian = FALSE, control = list(trace = 0), doy = doyP2, dbh = dbhP2)
	deriv.list <- lg5.deriv(OH.fit$par, doyP, growth = (log(b) - log(a)), shift = 0.05)
	resids.hull <- get.lg5.resids(OH.fit$par, doyP, dbhP)
	weighted.deficit <- resids.hull * deriv.list
	OH.list <- list(doyP2 = doyP2, dbhP2 = dbhP2, doyP = doyP, dbhP = dbhP, OH.fit = OH.fit, Derivatives = deriv.list, Deficit = resids.hull, Weighted.deficit = weighted.deficit)
	return(OH.list)
}

fit.outer.hull <- function(dbh, doy.full, params, quant = 0.8) {
	dbh <- as.numeric(dbh)
	complete <- complete.cases(dbh)
	dbh <- dbh[complete]
	doy <- doy.full[complete]
	out.fit <- outer.hull(params, doy, dbh)
}





###################################################
### code chunk number 13: day_values
###################################################
params <- Param.df[1,]
start.day <- round(pred.doy(params, params$a))
stop.day <- round(pred.doy(params, params$b))
.deriv <- lg5.deriv(paras = params, days, growth = params$b - params$a)
fifty.day <- round(pred.doy(params, mean(c(params$a, params$b))))


###################################################
### code chunk number 14: outerHull
###################################################

#pdf("figures/deficit_plot.pdf", width = 7, height = 10)

layout(matrix(c(1,1,1,1,2,2,3,3), ncol = 2, byrow = TRUE))
QH.list <- vector("list", dim(Param.df)[1])
WD.sum <- vector(length = dim(Param.df)[1])
D.sum <- vector(length = dim(Param.df)[1])
RGR <- vector(length = dim(Param.df)[1])
GR <- vector(length = dim(Param.df)[1])
Size <- vector(length = dim(Param.df)[1])

for(t in 1:dim(Param.df)[1]) {
	params <- Param.df[t, ]
	dbh <- as.numeric(dbh.data[t, ])
	doy.full <- get.doy(dbh.data)
	QH.list[[t]] <- fit.outer.hull(dbh, doy.full, params)
	OH.list <- QH.list[[t]]
	doyP2 <- OH.list$doyP2
	dbhP2 <- OH.list$dbhP2
	doyP <- OH.list$doyP
	dbhP <- OH.list$dbhP
	OH.fit <- OH.list$OH.fit

	D.sum[t] <- sum(OH.list$Deficit)
	WD.sum[t] <- sum(OH.list$Weighted.deficit)
	RGR[t] <- as.numeric(log(params$b) - log(params$a))
	GR[t] <- as.numeric(params$b - params$a)
	Size[t] <- params$a
	# Figure out start and stop values and days ... 
	start.d <- start.diam(params = as.numeric(params), seq.l = seq.l,  doy = doy, dbh, deviation.val = deviation.val, figure = FALSE, resid.sd)
	end.d <- end.diam(params = as.numeric(params), seq.l, doy, dbh, deviation.val, figure = FALSE, resid.sd)  	
	asym <- c(start.d[1], end.d[1])
	
}


###################################################
### code chunk number 15: comp.results.table
###################################################
# xtable(optim.output.df.1,
# 	digits = 4, caption = "Results from model runs using the 5-parameter
# 	Logistic Function. Parameter values are listed beside the optimization method.", label = "tab1")
write.csv(optim.output.df.1, file = "Optim_output.csv", quote = FALSE, row.names = FALSE)

###################################################
### code chunk number 16: data_fig
###################################################
plot(doy.1, dbh.1, xlab = "Day of the year", ylab = "DBH (cm)", pch = 18, 
     col = "tomato", main = "Cumulative annual growth")


###################################################
### code chunk number 17: four_examples
###################################################
par(mfrow = c(2,2), mar = c(4,4,2,2))
trees <- c(1, 5, 9, 17)
for(ct in 1:length(trees)) {
	t <- trees[ct]
	cex.val <- 0.8
	dbh <- as.numeric(dbh.data[t,])
	params.tmp <- as.numeric(Param.df[t, ])
	params.out.tmp <- subset(optim.output.df, Tree.no == t, select = -c(Tree.no, Optim.call, Best.ML))
	
	params.out <- as.matrix(params.out.tmp)
	complete <- complete.cases(dbh)
	dbh <- dbh[complete]
	doy <- doy.full[complete]
	cols <- brewer.pal(dim(optim.output)[1], name = "Dark2")

	plot(doy, dbh, xlab = "Day of the year", ylab = "DBH (cm)", pch = 19, col = "gray15", 
			main = sprintf("Annual Growth for tree %i", t), cex = 0.8, cex.axis = cex.val, 
			cex.lab = cex.val, cex.main = cex.val)
	
	days <- seq(365)
	for(j in 2:dim(params.out)[1]) {
		lines(days, lg5.pred(params = as.numeric(params.out[j ,]), doy = days), 
          col = cols[j - 1], lty = 2, lwd = 0.75)
	}	
	a <- params.tmp[6:7]
	lines(days, lg5.pred.a(a, params = params.tmp, doy = days, asymptote = "both"), 
			col = "darkred", lty = 1.5, lwd = 1)
	legend("topleft", legend = sprintf("%s)", letters[ct]), bty = "n", 
			cex = cex.val, inset)
	legend("bottomright", legend = c(calls[-1], "Lo-Hi"), col = c(cols, "darkred"), 
			lty = c(rep(2, 6), 1), lwd = 1, cex = 0.5)
}



###################################################
### code chunk number 18: plot_residuals
###################################################
par(mfrow = c(7, 1), mar = c(1,4,1,1))
doy <- doy1
dbh <- dbh1
for(i in 2:(dim(optim.output)[1])){
	params <- as.numeric(optim.output1[i,])
	lg5.resids <- get.lg5.resids(params, doy, dbh)
	plot(doy, lg5.resids, type = "b", col = "tomato", xlab = "Day of the Year", 
			pch = 19, ylab = sprintf("%s", calls[i]))
	abline(h = 0, col = "darkgrey")
}
mean.resids <- apply(resids.mat, MAR = 2,  mean, na.rm = TRUE)
sd.resids <- 1.96 * (apply(resids.mat, MAR = 2,  sd, na.rm = TRUE)  / sqrt(20))

plot(doy1, mean.resids, col = "steelblue", type = "b", pch = 19, ylab = "All trees")
segments(doy1, mean.resids - sd.resids, doy1, mean.resids + sd.resids, 
		col = "steelblue", lty = 1, lwd = 1.5)
abline(h = 0, col = "darkgray")


###################################################
### code chunk number 19: sparse_fig
###################################################
  par.name <- c("L", "K", "doy.ip", "r", "theta")
	par(mfrow = c(5,1), oma = c(1,1,1,1), mar = c(4,3,2,2))
	for(rs in 1:length(result.samp)){
		samp.data <- result.samp[[rs]]$par
    	if(rs == 3) {
      y.lim <-  c(150, 250)
    	} else {
      	y.lim <- range(samp.data[2:3,])
    	}
		plot(samp.data[4,], samp.data[3,], main = sprintf("%s", par.name[rs]), 
				ylab = "Estimate", xlab = ifelse(rs == 5, "Data points", ""), 
				col = "white", ylim = y.lim)
		polygon(c(samp.data[4,], rev(samp.data[4,])), c(samp.data[2,], 
						rev(samp.data[3,])), col = "lightblue")
		lines(samp.data[4,], samp.data[1,], col = "darkred", type = "b", pch = 19)
	}



###################################################
### code chunk number 20: quantile_hull
###################################################

#pdf("FIGURES/All_CH.pdf")
layout(matrix(c(1,1,1,1,2,2,3,3,4,4), ncol = 2, byrow = TRUE))
for(t in 1) { #:dim(Param.df)[1]) {
  params <- Param.df[t, ]
	dbh <- as.numeric(dbh.data[t, ])
	doy.full <- get.doy(dbh.data)
	doy <- doy.full[complete.cases(dbh)]
	dbh <- dbh[complete.cases(dbh)]
	OH.list <- fit.outer.hull(dbh, doy, params, quant = 0.8)
	
	doyP2 <- OH.list$doyP2
	dbhP2 <- OH.list$dbhP2
	doyP <- OH.list$doyP
	dbhP <- OH.list$dbhP
	OH.fit <- OH.list$OH.fit
# TODO: figure out start and stop values ... 
	start.d <- start.diam(params = as.numeric(params), seq.l = seq.l,  doy = doy, dbh, deviation.val = deviation.val, figure = FALSE, resid.sd)
	end.d <- end.diam(params = as.numeric(params), seq.l, doy, dbh, deviation.val, figure = FALSE, resid.sd)  	
	asym <- c(start.d[1], end.d[1])
	
	plot(doy, dbh, xlab = "", ylab = "DBH (cm)", pch = 19, col = "gray15", main = sprintf("Annual Growth for tree %i", t), cex = 1)
	points(doyP2, dbhP2, pch = 19, col = "tomato")
	days <- seq(365)
	lines(days, lg5.pred(params = OH.fit$par, doy = days), col = cols[1], lty = 1, lwd = 1)
	#lines(days, lg5.pred.a(asym, params = OH.fit$par, doy = days, asymptote = "upper"), col = cols[1], lty = 1, lwd = 1)
	lines(days, lg5.pred.a(asym, params = as.numeric(params), doy = days), col = cols[2], lty = 2, lwd = 1)
	legend("bottomright", lty = c(1,2), col = cols[1:2], legend = c("Quantile Hull", "ML fit"))
	text(110, 55.2, labels = "a)")
	
	plot(doyP, OH.list$Deficit, pch = 19, type = "b", xlim = range(doy), col = "steelblue", xlab = "", ylab = "Deficit")
	abline(h = 0)
	text(110, min(OH.list$Deficit), "b)", pos = 3)
	
	plot(doyP, OH.list$Weighted.deficit, pch = 19, type = "b", xlim = range(doy), col = "steelblue", xlab = "", ylab = "Weighted deficit")
	abline(h = 0)
	text(110, min(OH.list$Weighted.deficit), "c)", pos = 3)
	##
}
precip.data <- read.csv("WaterBalance.csv", header = TRUE)
plot(precip.data$doy, precip.data$cum.NET.3.1, col = "orange", type = "l", 
     xlim = range(doy), pch = 19, xlab = "Day of the Year", ylab = "Water balance (mm)")
  text(110, min(precip.data$cum.NET.3.1), "d)", pos = 3)



