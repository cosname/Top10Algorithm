Gaussian_NaiveBayes <- function(x, y) {
	require(plyr)
	#检查数据类型
	stopifnot(is.data.frame(x))
	stopifnot(is.numeric(y) | is.factor(y))
	y <- as.factor(y)

	#计算p(C)

	p_Ci <- table(y) / length(y)

	#求各个类的均值标准差

	df <- cbind(x,y)
	means <- aggregate(df, by = list(y), FUN = mean)
	sds <- aggregate(df, by = list(y), FUN = sd)
	means_df <- t(means[,2:(ncol(means) - 1)])
	sd_df <- t(sds[,2:(ncol(sds) - 1)])
	colnames(means_df) <- means[,1]
	colnames(sd_df) <- sds[,1]

	#训练集上的表现
	tr <- list(
		p_Ci,
		means_df,
		sd_df
		)
	names(tr) <- c('p_Ci', 'means', 'sds')
	class_train <- predict_Gaussian_NaiveBayes(x, tr)

	NB <- list(
		p_Ci,
		means_df,
		sd_df,
		class_train
		)
	names(NB) <- c('p_Ci', 'means', 'sds', 'class_train')

	return(NB)

}

predict_Gaussian_NaiveBayes <- function(x, Gaussian_NaiveBayes) {
	
	p_Ci <- Gaussian_NaiveBayes[['p_Ci']]
	means <- Gaussian_NaiveBayes[['means']]
	sds <- Gaussian_NaiveBayes[['sds']]

	#将均值和标准差整合到一个数据框中，再按种类分裂成列表
	#整理列表中数据框令均值和标准差分开不同的列
	mean_sd <- as.data.frame(rbind(means, sds))

	to_two_column <- function(x, mean_row) {
		result <- data.frame(
			x[1:mean_row],
			x[mean_row+1:length(x)]
			)
		colnames(result) <- c('mean', 'sd')
		result <- result[1:mean_row,]
		return(result)
	}

	mean_sd <- llply(mean_sd, .fun = to_two_column, nrow(means))

	#exp()部分
	#right <- exp((t(x) - u) ^ 2 / (2 * sd))
	#left <- 1 / sqrt(2 * pi * sd^2)

	little_little_fun <- function(x) {
		r <- 1
		for(i in 1:length(x)){
			r <- r * x[i]
		}
		return(r)
	}

	little_fun <- function(mean_sd, data) {
		left <- 1 / sqrt(2 * pi * (mean_sd$sd) ^ 2)
		right <- exp(- (t(data) - mean_sd$mean) ^ 2 / (2 * mean_sd$sd) ^ 2)
		pro <- left * right
		result <- apply(pro, 2, little_little_fun)
		return(result)
	}

	c_list <- llply(mean_sd, .fun = little_fun, x)
	pro_df <- do.call('cbind', c_list)
	pro_df <- t(t(pro_df) * c(p_Ci))

	get_class <- function(x) {
		classes <- names(x)
		class_loc <- match(max(x),x)
		return(classes[class_loc])
	}

	class_train <- apply(pro_df, 1, get_class)

	return(class_train)
}