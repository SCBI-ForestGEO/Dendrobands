# How to convert from dendrometer band measurements to DBH
##taken from Condit: http://richardcondit.org/data/dendrometer/calculation/Dendrometer.php

#first, functions are defined to resemble the equations described on the website. Each function is used in the following one.
objectiveFuncDendro= function(diameter2,diameter1,gap1,gap2){
  if(gap1>diameter1) return(20)
  if(gap2>diameter2) return(20)
    
  delta=abs(diameter1 - diameter2 + (1/pi) * diameter2 * asin(gap2/diameter2) - (1/pi) * diameter1 * asin(gap1/diameter1))
    
  return(return(delta))
}

findOneDendroDBH= function(dbh1,m1,m2,func=objectiveFuncDendro){
  if(is.na(dbh1)|is.na(m1)|is.na(m2)|dbh1<=0) return(NA)
    
  if(m2>0) upper=dbh1+m2
  else upper=dbh1+1
  if(m2<m1) lower=0
  else lower=dbh1
  
  result=optimize(f=func,interval=c(lower,upper),diameter1=dbh1,gap1=m1,gap2=m2)
  return(result$minimum)
}

findDendroDBH= function(dbh1,m1,m2,func=objectiveFuncDendro){
  records=max(length(dbh1),length(m1),length(m2))
  
  if(length(dbh1)==1) dbh1=rep(dbh1,records)
  if(length(m1)==1) m1=rep(m1,records)
  if(length(m2)==1) m2=rep(m2,records)
  
  dbh2=numeric()
  for(i in 1:records) dbh2[i]=findOneDendroDBH(dbh1[i],m1[i],m2[i],func)
  return(dbh2)
}

#next, with sample data of dbh1, measure 1, and measure 2, here's an example of what the derived dbh would be based on measurements.
dbh1 = c(100, 200, 300, 100, 200, 300)
m1 = c(0, 0, 0, 0, 0, 0)
m2 = c(2, 2, 2, 50, 50, 50)
dbh2 = findDendroDBH(dbh1, m1, m2)
data.frame(dbh1, m1, m2, dbh2)

#here is the ctfs R package from Condit: http://ctfs.si.edu/Public/CTFSRPackage/
