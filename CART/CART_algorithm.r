###############################################决策树############################################

install.packages("rpart")
library(rpart)
###生成树
raprt(formular           #模型格式形如　y～x1+x2+x3
     ,data               #包含前面方程中变量的数据框(data frame) 
	 ,na.action          #缺失数据的处理办法，默认为删除因变量缺失的观测而保留自变量缺失的观测
	 ,method             #"树的末端数据类型选择相应的变量分割方法，连续性method=“anova”,离散型使用method=“class”,，计数型method=“poisson”,生存分析型method=“exp”,
	                     #程序会根据因变量的类型自动选择方法,但一般情况下最好还是指明本参数,以便让程序清楚做哪一种树模型，若因变量是离散型的话，要用as.factor将其转换为factor型，否则会报错
	 ,parms              #prior这个参数主要用来设定先验概率，一般在处理类不平衡问题时需要调整，默认值为样本类分布比例；另外一个参数split主要是用来进行特征选择分裂的标准，
	                     #分gini和information种方式，默认是前者。
	 ,control            #一系列关于模型参数的列表，详细参考rpart.control。控制每个节点上的最小样本量，交叉验证的次数，复杂性参量：cp:complexity pamemeter,这个参数意味着对每一步拆分,模型的拟合优度必须提高的程度,等等
	 )  
	 
rpart.control(minsplit = 20                   # 内部中指定的最小样本数，作为停止树生长或者分裂的条件。
             ,minbucket = round(minsplit/3)   # 叶结点指定的最小样本数，minbucket和minsplit任意指定一个即可.若minsplit指定为x，则minbucket相应的就为x/3;若minbucket指定为x，则minsplit相应的就为3x;
			 ,cp = 0.01                       # 指定模型复杂度参数的，也就是前面讲到的α，默认取值0.01
			 ,maxcompete,maxsurrogate,usesurrogate # 这几个参数主要和CART将模型运用到新数据时遇到一些特征有缺失值时使用的一种叫代理分裂点(surrogate splits)有关
			 ,xval = 10                       # 交叉验证次数，这个主要用于选择最优子树序列用的
			 ,maxdepth = 30                   # 指定树的最大深度，当然树越深的话越复杂
			 ,...)	 
###剪枝
prune(tree               #tree常是rpart()的结果对象
     ,cp                 #复杂性参数值,指定剪枝采用的阈值。
	 )   
#模型结果解读
> library(raprt)
> fit <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
> fit
n= 81 

node), split, n, loss, yval, (yprob)
      * denotes terminal node

 1) root 81 17 absent (0.79012346 0.20987654)  
   2) Start>=8.5 62  6 absent (0.90322581 0.09677419)  
     4) Start>=14.5 29  0 absent (1.00000000 0.00000000) *
     5) Start< 14.5 33  6 absent (0.81818182 0.18181818)  
      10) Age< 55 12  0 absent (1.00000000 0.00000000) *
      11) Age>=55 21  6 absent (0.71428571 0.28571429)  
        22) Age>=111 14  2 absent (0.85714286 0.14285714) *
        23) Age< 111 7  3 present (0.42857143 0.57142857) *
   3) Start< 8.5 19  8 present (0.42105263 0.57894737) *
###运用模型进行预测
> fit <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)   
> table(predict(fit, iris[-sub,], type = "class"), iris[-sub, "Species"])  # predict函数主要的参数是type，能够还回类概率值或者类标签；这句脚本生成混淆矩阵，直接极速precision和recall
