set.seed(1000)
height<-c(rnorm(12000,171,10),rnorm(10000,155,8))
hist(height,breaks=100,prob=T,main="")
lines(density(height),col="red")


mu1<-140
mu2<-180
sd1<-5
sd2<-5
w<-0.5
diff<-1
sim<-c(rnorm(22000*w,mu2,sd2),rnorm(22000*(1-w),mu1,sd1))
hist(height,breaks=100,prob=T,main="",ylim=c(0,.04))
lines(density(sim),col="blue")

dens1<-dnorm(height,mu1,sd1)
dens2<-dnorm(height,mu2,sd2)
likelihood<--sum(log(max(dens1*(1-sex),dens2*sex)))

#E step
sex<-rep(0,22000)
sex[runif(22000)>dens1*(1-w)/(dens1*(1-w)+dens2*w)]<-1
par(mfrow=c(1,1))
hist(height[sex==0],breaks=100,prob=T,main="",xlim=c(120,200),ylim=c(0,0.08),xlab="Female")
lines(density(height[sex==0]))
hist(height[sex==1],breaks=100,prob=T,main="",xlim=c(120,200),ylim=c(0,0.08),xlab="Male")
lines(density(height[sex==1]))


#M step
w<-mean(sex)
mu1<-mean(height[sex==0])
mu2<-mean(height[sex==1])
sd1<-sd(height[sex==0])
sd2<-sd(height[sex==1])
c(mu1,mu2,sd1,sd2,w)

sim<-c(rnorm(22000*w,mu2,sd2),rnorm(22000*(1-w),mu1,sd1))
hist(height,breaks=100,prob=T,main="",ylim=c(0,.04))
lines(density(sim),col="blue")


#criterion
dens1<-dnorm(height,mu1,sd1)
dens2<-dnorm(height,mu2,sd2)
diff<-abs(-sum(log(max(dens1*(1-sex),dens2*sex)))-likelihood)
likelihood<--sum(log(max(dens1*(1-sex),dens2*sex)))

lp<-1

while(diff>.00001){
  #E step
  sex<-rep(0,22000)
  sex[runif(22000)>dens1*(1-w)/(dens1*(1-w)+dens2*w)]<-1
  #M step
  w<-mean(sex)
  mu1<-mean(height[sex==0])
  mu2<-mean(height[sex==1])
  sd1<-sd(height[sex==0])
  sd2<-sd(height[sex==1])
  #criterion
  dens1<-dnorm(height,mu1,sd1)
  dens2<-dnorm(height,mu2,sd2)
  diff<-abs(-sum(log(max(dens1*(1-sex),dens2*sex)))-likelihood)
  likelihood<--sum(log(max(dens1*(1-sex),dens2*sex)))
  lp<-lp+1
}

c(mu1,mu2,sd1,sd2,w,lp)

