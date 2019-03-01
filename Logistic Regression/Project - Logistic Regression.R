# Predict if people belong in a certain class by salary, either making <=50k or >=50k
adult <- read.csv('adult_sal.csv')
head(adult)
table(adult$country)

library(dplyr)
adult <- select(adult,-X)
head(adult)
str(adult)
summary(adult)

# Data Cleaning

table(adult$type_employer)
  "There are 1836 null values, the smallest group is the 'never-worked' group"

## Combine 'Never-worked' and 'Without-pay' into 'Unemployed'
  unemp <- function(x){
      x <- as.character(x)
      if (x == 'Never-worked' | x=='Without-pay'){
        return('Unemployed')
      }else{
        return(x)
      }
    }
  
  adult$type_employer <- sapply(adult$type_employer, unemp)
  adult$type_employer <- factor(adult$type_employer)
  
## Combine 'State-gov' and 'Local-gov' into 'SL-gov'
  gov <- function(x){
    x <- as.character(x)
    if (x=='State-gov' | x=='Local-gov'){
      return('SL-gov')
    }else{
      return(x)
    }
  }
  adult$type_employer <- sapply(adult$type_employer, gov)
  table(adult$type_employer)
    
## Combine 'Self-emp-inc' and 'Self-emp-not-inc' into 'Self-emp'
  self <- function(x){
    x <- as.character(x)
    if (x=='Self-emp-inc' | x=='Self-emp-not-inc'){
      return('Self-emp')
    }else{
      return(x)
    }
  }
  adult$type_employer <- sapply(adult$type_employer, self)
  table(adult$type_employer)

## Reduce Marital column to 'Married', 'Not-Married', 'Never-Married'
  table(adult$marital)
  SO <- function(x){
    x <- as.character(x)
    if (x=='Married-spouse-absent' | x=='Married-AF-spouse' | x=='Married-civ-spouse'){
      return('Married')
    }else if (x=='Divorced' | x=='Separated' | x=='Widowed'){
      return('Not Married')
    }else{
      return('Never Married')
    }
  }
  adult$marital <- sapply(adult$marital, SO)  
  adult$marital <- factor(adult$marital)  

## Group the countries column  
  continents <- function(x){
    x <- as.character(x)
    if(x=='France'|x=='Holand-Netherlands'|x=='Germany'|x=='Cambodia'|x=='Ireland'
       |x=='Poland'|x=='Yugoslavia'|x=='Portugal'|x=='Greece'|x=='Italy'|x=='Hungary'|x=='England'|x=='Scotland'){
      return('Europe')
    }else if(x=='Vietnam'|x=='Philippines'|x=='Iran'|x=='Hong'|x=='South'|x=='Philippenes'|x=='Taiwan'|x=='Thailand'|x=='China'|x=='India'|x=='Japan'|x=='Laos'){
      return('Asia')
    }else if(x=='El Salvador'|x=='Guatemala'|x=='Jamaica'
             |x=='Outlying-US(Guam-USVI-etc)'|x=='Trinadad&Tobago'|x=='Mexico'
             |x=='Honduras'|x=='Nicaragua'|x=='Cuba'){
      return('Central America')
    }else if(x=='Columbia'|x=='Ecuador'|x=='Peru'|x=='Dominican-Republic'){
      return('South America')
    }else if(x=='Puerto-Rico'|x=='United-States'|x=='Canada'|x=='Haiti'|x=='El-Salvador'){
      return('North America')
    }else{
      return(x)
    }
  }
  adult$country <- sapply(adult$country,continents)
  adult$country <- factor(adult$country)
  table(adult$country)  
str(adult)
  
# Missing Data
library(Amelia)
## Convert ? to NA
adult[adult == '?'] <- NA # Cheated
## Refactor data
adult$education <- factor(adult$education)
adult$marital <- factor(adult$marital)
adult$occupation <- factor(adult$occupation)
adult$relationship <- factor(adult$relationship)
adult$race <- factor(adult$race)
adult$sex <- factor(adult$sex)
adult$country <- factor(adult$country)

missmap(adult)
## Sample args. yellow = missing, black = observed.
missmap(adult,y.at=c(1),y.labels = c(''),col=c('yellow','black'))
## Get rid of NaNs
adult <- na.omit(adult)
str(adult)
## Double check no NaNs
missmap(adult,y.at=c(1),y.labels = c(''),col=c('yellow','black'))

# Exploratory Data Analysis
str(adult)
library(ggplot2)
## Histogram of ages, by income
pl <- ggplot(data=adult,aes(age))
pl + geom_histogram(aes(fill=income),color='black')
## Histogram of hours worked/week
pl2 <- ggplot(data=adult,aes(hr_per_week))
pl2 + geom_histogram(aes(fill=income))

## Rename country column
adult$region <- adult$country
adult <- select(adult,-country) # remove the country column
pl3 <- ggplot(data=adult,aes(region))
pl3 + geom_bar(aes(fill=income),color='black')

# Build a Model

## Split the data

head(adult)
library(caTools)
set.seed(101)
split <- sample.split(adult$income,SplitRatio=0.7)  # 70% will be TRUE
ad.train <- subset(adult,split==T)
ad.test <- subset(adult,split==F)

str(ad.train)
?glm

adult.logit <- glm(income~.,family=binomial(logit),data=ad.train)
summary(adult.logit)

## Refine the model
?step ## Uses akaike information criterion to remove predictors not relevant to the model
### AIC estimates the relative amount of information lost by a given model: the less information a model loses, the higher the quality of that model. 
### In estimating the amount of information lost by a model, AIC deals with the trade-off between the goodness of fit of the model and the simplicity of the model. In other words, AIC deals with both the risk of overfitting and the risk of underfitting. 
### The smaller the AIC the better the model
### AIC only tells the qualitive of a model relative to other models
### Note that AIC tells nothing about the absolute quality of a model, only the quality relative to other models. Thus, if all the candidate models fit poorly, AIC will not give any warning of that. Hence, after selecting a model via AIC, it is usually good practice to validate the absolute quality of the model. Such validation commonly includes checks of the model's residuals (to determine whether the residuals seem like random) and tests of the model's predictions. For more on this topic, see statistical model validation. 

new.model <- step(adult.logit)
summary(new.model)

## Analyze the model

### Create a Confusion Matrix

fitted.probabilities <- predict(new.model,newdata=ad.test, type='response')
table(ad.test$income, fitted.probabilities > 0.5)

#--- Cheated --- #
### Check the performance of the model
#### Accuracy
  fitted.results <- ifelse(fitted.probabilities > 0.5, 1, 0)
  misClasificError <- mean(fitted.results != ad.test)
  print(paste('Accuracy was: ', misClasificError))
  
  # Answer: 
  (6282+1349)/(6282+902+514+1349)
  
#### Recall:
  
  (6282)/(6282+514)
  
#### Precision:
  
  (6282)/(6282+903)
  