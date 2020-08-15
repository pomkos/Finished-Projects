---
title: "Project - Linear Regression"
author: "Peter"
date: "February 24, 2019"
output: html_document
---

```{r}
library(ggplot2)
library(dplyr)
library(caTools)

bike <- read.csv('bikeshare.csv')
head(bike)
any(is.na(bike))
str(bike)
```

We are going to predict the count (total rentals per hour)

# Exploratory Data Analysis

## Scatterplot, temp v count

```{r}
pl <- ggplot(data=bike, aes(x=temp,y=count))
pl + geom_point(aes(color=temp,alpha=0.5))
```

As temperature goes up, the number of total rentals also go up.

## Scatterplot, datetime v count

```{r}
bike$datetime2 <- as.POSIXct(bike$datetime)
pl2 <- ggplot(data=bike,aes(x=datetime2,y=count))
pl2 + geom_point(aes(color=temp, alpha=0.5)) + scale_color_gradient(low='green',high='red')
```

Summer months get more total rentals, but also total rentals increase year to year.

## Correlation, temp v count

```{r}
cor(x=bike$temp,y=bike$count)
```

Temperature and total bike rentals are positively but loosely correlated. As seen in the first scatterplot.

## Boxplot, seasons v count

```{r}
pl3 <- ggplot(data=bike,aes(x=season,y=count))
pl3 + geom_boxplot(aes(color=factor(season)))
```

For interpretation of boxplots checkout [this](https://www.mathbootcamps.com/how-to-read-a-boxplot/) guide.

Seasons 1=spring, 2=summer, 3=fall, 4=winter

| Spring                                    | Summer                                    | Fall                                     | Winter                                    |   |
|-------------------------------------------|-------------------------------------------|------------------------------------------|-------------------------------------------|---|
| 50% of the seasons had around 100 rentals |  50% of the season had around 150 rentals | 50% of the season had around 175 rentals |  50% of the season had around 140 rentals |   |

There is a lot of variance in total rental sales per season. Likely due to temperature, weekday v weekend, etc.

# Feature Engineering

## Using normal functions

```{r}
hours <- function(x){
  time.stamp <- x
  format(time.stamp, "%H")
}
bike$hours <- lapply(bike$datetime2,hours)
```

## Using anonymous function

```{r}
bike$hours <- lapply(bike$datetime2, function(x){format(time.stamp<-x,"%H")})
head(bike)
```

We extracted the hours from the datetime in order to be able to create the scatterplots below.

## Scatterplot, hour v count

```{r}
bike$hours <- as.integer(bike$hours)
bike.work <- filter(bike,workingday==1)
pl4 <- ggplot(data=bike.work,aes(x=factor(hours),y=count))
pl4 + geom_point(aes(color=temp, alpha=0.5),position = position_jitter(w=1,h=0)) + scale_color_gradientn(colors=c('blue','green','yellow','red'))
```

During the weekdays, peak total rentals occurred between 7-9am and 4-8pm. During higher temperatures there were more rentals.

```{r}
bike.nonwork <- filter(bike,workingday==0)
pl5 <- ggplot(bike.nonwork,aes(x=factor(hours),y=count))
pl5 + geom_point(aes(color=temp, alpha=0.5),position = position_jitter(w=1,h=0)) + scale_color_gradientn(colors=c('blue','green','yellow','red'))
```

During the weekends, there were high amount of rentals throughout the day. During higher temperatures there were more rentals.

# Building the Model 1

```{r}
temp.model <- lm(count~temp,data=bike)
summary(temp.model)

predict(temp.model,data.frame(temp=25))
```
Temperature only explains 15% of variability in total bike rentals. Our model predicts with 15% certainty that 235 bike rentals will occur when the temperature is 25C.

# Building the Model 2

```{r}
bike$num.hours <- sapply(bike$hours, function(x){as.numeric(x)})
all.model <- lm(count~. -datetime-atemp-casual-registered-count-datetime2-hours,data=bike)
summary(all.model)
```
This data does not fit a lm very well, even though p<0.0001. R^2 = 0.33.

## Problems with the Linear Model

### Nonlinearity

```{r}
par(mfrow=c(2,2))
plot(all.model)
```

```{r}
plot(x=predict(all.model), y=residuals(all.model),
     xlab = 'Fitted Values',
     ylab = 'Residuals',
     main = 'Residual Plot')
```

* There is a clear pattern in residuals, the linear model is thus not a good fit.

### Correlation of error terms

* Not sure how to show whether or not tracking appears in the residuals.

### Non-constant variance of error terms

```{r}
plot(x=predict(all.model), y=residuals(all.model),
     xlab = 'Fitted Values',
     ylab = 'Residuals',
     main = 'Residual Plot')
```

* Residual plot indicates heteroscedasticity, so the error terms have non-constant variance from the regression line.

### Outliers

```{r}
plot(x=predict(all.model), y=rstudent(all.model),
     xlab = 'Fitted Values',
     ylab = 'Studentized Residuals',
     main = 'Studentized Residual Plot')
```

* Residual plot shows no clear outliers
* Studentized residual plot shows lots of 'possible outliers' as their stundentized residual > 3

### High-leverage points

```{r}
pl6 <- ggplot(bike,aes(x=hatvalues(all.model),y=rstudent(all.model)))
pl6 + geom_point(aes(alpha=0.5)) + 
  xlab('Leverage Statistics') + 
  ylab('Studentized Residuals') +
  ggtitle('Analysis of Leverage Statistics')
```

* Plot shows some observations with outlying leverages that are still well below 1, and no real high-leverage points. 

```{r}
max(hatvalues(all.model))
```

* The maximum leverage statistic is 0.005, not indicating a high-leverage point.

### Collinearity

```{r}
library(car) # has vif function
vif(all.model)
```

* VIF values > 5 or 10 would indicate too much collinearity
* All observed VIF values are ~1, indicating no collinearity

## Steps in linear regression analysis:

```{r}
summary(all.model)
```

1. Our linear model is significant (F=683, p < 0.0001)
2. Variables not significantly correlated with total rental count include holiday, workingday, weather, windspeed.
3. A high RSE of 147.8 indicates lots of deviation from the linear regression line. Low R^2 of 0.33 indicates only 33% of variability in total rental count is explained by our predictors using the linear model.
4. I did not do prediction with this model.

## Conclusion

A linear model does not fit the data as evidenced by:

* Clear pattern in the residual plot
* Non-constant variance of residual error terms
* Presence of outliers
* (Error terms were not correlated)
* (There is no presence of high leverage points)
* (There is no presence of collinearity)
