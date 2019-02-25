library(ggplot2)
library(dplyr)
library(caTools)

bike <- read.csv('bikeshare.csv')
head(bike)
any(is.na(bike))
str(bike)

### We are going to predict the count (total rentals per hour)

# Exploratory Data Analysis
## Scatterplot, temp v count
pl <- ggplot(data=bike, aes(x=temp,y=count))
pl + geom_point(aes(color=temp,alpha=0.5))

## Scatterplot, datetime v count
bike$datetime2 <- as.POSIXct(bike$datetime)
pl2 <- ggplot(data=bike,aes(x=datetime2,y=count))
pl2 + geom_point(aes(color=temp, alpha=0.5)) + scale_color_gradient(low='green',high='red')

## Correlation, temp v count
cor(x=bike$temp,y=bike$count)

## Boxplot, seasons v count
pl3 <- ggplot(data=bike,aes(x=season,y=count))
pl3 + geom_boxplot(aes(color=factor(season)))

# Feature Engineering
## Using normal functions
hours <- function(x){
  time.stamp <- x
  format(time.stamp, "%H")
}
bike$hours <- lapply(bike$datetime2,hours)
## Using anonymous function
bike$hours <- lapply(bike$datetime2, function(x){format(time.stamp<-x,"%H")})

head(bike)

## Scatterplot, hour v count
bike$hours <- as.integer(bike$hours)
bike.work <- filter(bike,workingday==1)
pl4 <- ggplot(data=bike.work,aes(x=factor(hours),y=count))
pl4 + geom_point(aes(color=temp, alpha=0.5),position = position_jitter(w=1,h=0)) + scale_color_gradientn(colors=c('blue','green','yellow','red'))

bike.nonwork <- filter(bike,workingday==0)
pl5 <- ggplot(bike.nonwork,aes(x=factor(hours),y=count))
pl5 + geom_point(aes(color=temp, alpha=0.5),position = position_jitter(w=1,h=0)) + scale_color_gradientn(colors=c('blue','green','yellow','red'))

# Building the Model 1
temp.model <- lm(count~temp,data=bike)
summary(temp.model)

predict(temp.model,data.frame(temp=25))

# Building the Model 2
bike$num.hours <- sapply(bike$hours, function(x){as.numeric(x)})
all.model <- lm(count~. -datetime-atemp-casual-registered-count-datetime2-hours,data=bike)
summary(all.model)

'This data does not fit a lm very well, even though p<0.0001. R^2 = 0.33.'

# Bonus
set.seed(101)
sample <- sample.split(bike$hours, SplitRatio = 0.7)

## Training Data
train = subset(bike, sample==T)
head(train)

## Testing Data
test = subset(bike, sample==F)
head(test)

temp2.model <- lm(count~temp,data=test)
summary(temp2.model)

predict(temp2.model,data.frame(temp=25))
