Bernoulli_NaiveBayes <- function(x, y) {
	require(plyr)

	#和多项式的一模一样，算出p(C)和p
	stopifnot(is.data.frame(x))
	stopifnot(is.numeric(y) | is.factor(y))
	y <- as.factor(y)
	x <- round(x)

	#检查输入的x是不是01矩阵，若不是，转化为01矩阵
	if(max(x) > 1){
		x <- split(x, row(x))
		turn <- function(x) {
			x[which(x > 1)] <- 1
			return(x)
		}
		x <- llply(x, .fun = turn)
		x <- do.call('rbind', x)
	}else{}

	#计算p(C)并将其放入数据中

	p_Ci <- table(y) / length(y)

	print('p_Ci done.')

	#计算p, k为出现的次数，n为总体数
	dat <- cbind(x, y)

	class_list <- split(dat, y)

	print('split done')

	#n和p(C)有一样的长度
	#除y外对所有列求和
	sum_col <- function(x) {
		x <- sum(x[,-ncol(x)])
		return(x)
	}
	n <- laply(class_list, sum_col)

	print('n done')

	#计算k.
	
	Culculate_k <- function(x) {
		x <- x[, -ncol(x)]
		k <- apply(x, 2, sum)
		return(k)
	}

	k_list <- llply(class_list, Culculate_k)

	print('k_list done')
	
	#计算k/n,即p
	#将k转换成矩阵，方便计算 
	k_matrix <- do.call('cbind', k_list)

	print('k_matrix done')

	#将n转换为对角阵
	n_matrix <- diag(1/n)
	#计算p，返回概率矩阵
	p <- k_matrix %*% (n_matrix)
	colnames(p) <- colnames(k_matrix)

	print('p done')

	#训练集上的表现
	tr <- list(p_Ci, p)
	names(tr) <- c('p_Ci', 'p')
	class_train <- predict_Multi_NaiveBayes(x, tr)

	NB <- list(
		p_Ci,
		p,
		class_train)
	names(NB) <- c('p_Ci', 'p', 'class_train')
	return(NB)
}

predict_Bernoulli_NaiveBayes <- function(x, Bernoulli_NaiveBayes) {
	p_Ci <- Bernoulli_NaiveBayes[['p_Ci']]
	p <- Bernoulli_NaiveBayes[['p']]

	#和训练函数一样，转换矩阵
	if(max(x) > 1){
		turn <- function(x) {
			x[which(x > 1)] <- 1
			return(x)
		}
		x <- apply(x, 1, turn)
	}else{}
	x <- round(x)

	#计算k*(p) + (1 - k) * (1 - p)
	c_list <- list()
	for(i in 1:ncol(p)){
		c_list[[i]] <- t(p[,i] * t(x) + (1 - p[,i]) * (t(1 - x)))
	}

	names(c_list) <- colnames(p)

	print('predict k*(p) ... done')

	little_little_fun <- function(x) {
		r <- 1
		for(i in 1:length(x)){
			r <- r * x[i]
		}
		return(r)
	}
	little_fun <- function(x) {
		s <- split(x, row(x))
		l <- lapply(s, little_little_fun)
		l <- do.call('rbind', l)
		return(l)
	}
	multi_dis <- lapply(c_list, little_fun)
	multi_dis <- do.call('cbind', multi_dis)
	colnames(multi_dis) <- colnames(p)

	#train_pro为属于各个类的概率
	train_pro <- c(p_Ci) * t(multi_dis)
	train_pro <- t(train_pro)
	names(train_pro) <- names(p_Ci)

	#class_train为最终训练集分类结果
	get_class <- function(x) {
		classes <- names(x)
		class_loc <- match(max(x),x)
		return(classes[class_loc])
	}

	class_train <- apply(train_pro, 1, get_class)

	return(class_train)

}