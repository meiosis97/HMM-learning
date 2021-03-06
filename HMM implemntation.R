A <- matrix(c(0.4,0.6,0.2,0.8), ncol = 2, byrow = T)
pi <- c(0.5,0.5)
mu <- c(5,3)

n <- 100
z <- c()
z[1] <- sample(c(1,2), prob = pi, size = 1)
for(i in 2:100){
  
  z[i] <- sample(c(1,2), prob = A[z[i-1],], size = 1)

}


x <- rnorm(100, mean = ifelse(z == 1, mu[1], mu[2]))





logs1 <- function(z, x, pi, mu){
  
  
  log(pi[z]) + dnorm(x, mu[z], log = T)

}




logsi <- function(z, logs, x, A, mu){
  
  lik <- 0 
  a <- c()
  
  
  for(i in 1:length(pi)){
    
    a[i] <- logs[i]+log(A[i,z]) + dnorm(x, mu[z], log = T)
    
  }
  
  b <- max(a)
  
  for(i in 1:length(pi)){
    
    lik <- lik + exp(a[i] - b)
  
  }
  
  
  b + log(lik)
  
  
}


logs <- function(x, pi, mu, A){

  s <- matrix(nrow = n, ncol = 2)
  s[1,] <- c(logs1(1,x[1],pi,mu), logs1(2,x[1],pi,mu))
  
  for(i in 2:n){
    
    s[i,] <- c(logsi(1,s[i-1,], x[i], A, mu), logsi(2,s[i-1,], x[i], A, mu))
    
    
  }

  s
  
}





logri <- function(z, logr, x, A, mu){
  
  
  lik <- 0 
  a <- c()
  
  
  for(i in 1:length(pi)){
    
    a[i] <- logr[i]+log(A[z,i]) + dnorm(x, mu[i], log = T)
    
  }
  
  b <- max(a)
  
  for(i in 1:length(pi)){
    
    lik <- lik + exp(a[i] - b)
    
  }
  
  
  b + log(lik)
  
  
  
}




logr <- function(x, mu, A){
  
  r <- matrix(nrow = n, ncol = 2)
  
  r[n,] <- c(1, 1)
  
  for(i in (n-1):1){
    
    r[i,] <- c(logri(1,r[i+1,], x[i+1], A, mu), logri(2,r[i+1,], x[i+1], A, mu))
    
    
  }
  
  r
  
}


s <- logs(x,pi,mu,A)
r <- logr(x,mu,A)

log.gamma <- s + r
gamma <- log.gamma
gamma[,1] <- exp(gamma[,1] - gamma[,2])
gamma[,1] <- gamma[,1]/(1 + gamma[,1])
gamma[,2] <- 1-gamma[,1]

log.beta <- matrix(ncol = 4, nrow = n-1)
for(i in 1:nrow(log.beta)){
  
  log.beta[i,1] <- s[i,1] + log(A[1,1]) + dnorm(x[i+1],mu[1], log = T) + r[i+1,1]
  log.beta[i,2] <- s[i,1] + log(A[1,2]) + dnorm(x[i+1],mu[2], log = T) + r[i+1,2]
  log.beta[i,3] <- s[i,2] + log(A[2,1]) + dnorm(x[i+1],mu[1], log = T) + r[i+1,1]
  log.beta[i,4] <- s[i,2] + log(A[2,2]) + dnorm(x[i+1],mu[2], log = T) + r[i+1,2]
  
  
  
  
  
}

beta <- log.beta
beta[,1] <- exp(beta[,1] - beta[,2])
beta[,3] <- exp(beta[,3] - beta[,4])
beta[,1] <- beta[,1]*gamma[-n,1]/(gamma[-n,1] + beta[,1])
beta[,3] <- beta[,3]*gamma[-n,2]/(gamma[-n,2] + beta[,3])
beta[,2] <- gamma[-n,1]-beta[,1]
beta[,4] <- gamma[-n,2]-beta[,3]

































ini.pi = c(0.3, 0.7)
ini.mu = c(2, 1)
ini.A = matrix(c(0.2,0.8,0.4,0.6), ncol = 2, byrow = T)


for(j in 1:18){
  
  
  s <- logs(x,ini.pi,ini.mu,ini.A)
  r <- logr(x,ini.mu,ini.A)
  
  log.gamma <- s + r
  gamma <- exp(log.gamma)
  
  for(i in 1:nrow(gamma)){
    
    gamma[i,] <- gamma[i,] /sum(gamma[i,])
    
  }
  
  
  
  
  log.beta <- matrix(ncol = 4, nrow = n-1)
  for(i in 1:nrow(log.beta)){
    
    log.beta[i,1] <- s[i,1] + log(A[1,1]) + dnorm(x[i+1],mu[1], log = T) + r[i+1,1]
    log.beta[i,2] <- s[i,1] + log(A[1,2]) + dnorm(x[i+1],mu[2], log = T) + r[i+1,2]
    log.beta[i,3] <- s[i,2] + log(A[2,1]) + dnorm(x[i+1],mu[1], log = T) + r[i+1,1]
    log.beta[i,4] <- s[i,2] + log(A[2,2]) + dnorm(x[i+1],mu[2], log = T) + r[i+1,2]
    
    
  }
  
  beta <- exp(log.beta)
  
  for(i in 1:nrow(log.beta)){
    
    beta[i,] <- beta[i,] /sum(beta[i,])
    
  }
  
  
  
  
  
  ini.pi <- gamma[1,]
  ini.mu <- c(sum(gamma[,1] * x)/sum(gamma[,1]), sum(gamma[,2] * x)/sum(gamma[,2]))
  ini.A[1,] <- c(sum(beta[,1])/sum(gamma[-n,1]), sum(beta[,2])/sum(gamma[-n,1]))
  ini.A[2,] <- c(sum(beta[,3])/sum(gamma[-n,2]), sum(beta[,4])/sum(gamma[-n,2]))
  
  print(ini.pi)
  
}

