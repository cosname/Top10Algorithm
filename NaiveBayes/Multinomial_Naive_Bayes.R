Multi_NaiveBayes <- function(x, y) {
	#函数接受的x应为data.frame,y为数值型或因子



	require(plyr)
	#检查数据类型
	stopifnot(is.data.frame(x))
	stopifnot(is.numeric(y) | is.factor(y))
	y <- as.factor(y)
	x <- round(x)

	#计算p(C)

	p_Ci <- table(y) / length(y)

	#计算k/n
	#用极大似然估计估计出来的p等于k/n，因此此处直接用k/n
	dat <- cbind(x, y)

	class_list <- split(dat, y)

	#n和p(C)有一样的长度
	#除y外对元素求和，得到n
	sum_col <- function(x) {
		x <- sum(x[,-ncol(x)])
		return(x)
	}
	n <- laply(class_list, sum_col)

	#计算k.
	
	Culculate_k <- function(x) {
		x <- x[, -ncol(x)]
		return(colSums(x))
	}

	k_list <- llply(class_list, Culculate_k)
	
	#计算k/n,即p
	#将k转换成矩阵，方便计算 
	k_matrix <- do.call('cbind', k_list)

	#将n转换为对角阵
	n_matrix <- diag(1/n)
	#计算p，返回概率矩阵
	#p是列为类别，行为特征的概率矩阵
	p <- k_matrix %*% (n_matrix)
	colnames(p) <- colnames(k_matrix)
	
	#计算C(n,k) * (p)^k * (1-p)^(n-k)
	tr <- list(p_Ci, p)
	names(tr) <- c('p_Ci', 'p')
	class_train <- predict_Multi_NaiveBayes(x, tr)

	
	#最终结果

	NB <- list(
		p_Ci,
		p,
		class_train)
	names(NB) <- c('p_Ci', 'p', 'class_train')
	return(NB)
}

predict_Multi_NaiveBayes <- function(x, Multi_NaiveBayes) {

	p_Ci <- Multi_NaiveBayes[['p_Ci']]
	p <- Multi_NaiveBayes[['p']]
	x <- round(x)

	n2 <- apply(x, 1, sum) #特征频率总和

	#cnk为C(n,k), minus 为(n-k)
	cnk <- matrix(ncol = ncol(x), nrow = nrow(x))
	minus <- cnk
	for(i in 1:length(n2)){
		cnk[i,] <- choose(n2[i], t(x[i,]))
		minus[i,] <- n2[i] - t(x[i,]) 
	}
	colnames(cnk) <- colnames(x)
	colnames(minus) <- colnames(x)
	
	c_list <- list()
	for(i in 1:ncol(p)){
		c_list[[i]] <- cnk * t(p[,i]^t(x)) * t((1-p[,i])^t(minus))
	}
	names(c_list) <- colnames(p)
	#c_list为属于各个种类的C(n,k) * (p)^k * (1-p)^(n-k), multi_dist为合并为矩阵
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

	get_class <- function(x) {
		classes <- names(x)
		class_loc <- match(max(x),x)
		return(classes[class_loc])
	}

	class_train <- apply(train_pro, 1, get_class)

	return(class_train)
}
