ST 558 Project 3 Analysis
================
Carter Hall, Autumn Locklear
2023-11-05

# Introduction

The following analysis uses a subset of data from the 2015 Behavioral
Risk Factor Surveillance System (BRFSS). The specific data set includes
a binary variable for diabetes, and other categorical variables to
represent health risk factors such as heart disease, high cholesterol,
and smoking status.

The purpose of this Exploratory Data Analysis is to better understand
the dataset variables and the relationship between them. The purpose of
modeling is to predict whether or not a patient is at risk for diabetes
based on other health indicators.

# Data

``` r
# Importing the Data
diab <- read_csv("diabetes_binary_health_indicators_BRFSS2015.csv")
```

    ## Rows: 253680 Columns: 22
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## dbl (22): Diabetes_binary, HighBP, HighChol, CholCheck, BMI, Smoker, Stroke,...
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
#' Context on the `Education` variable:
#' 1 := Never attended school or at most kindergarten
#' 2 := Grades 1-8   [1 and 2 Renamed to Group 1]
#' 3 := Grades 9-11          [Renamed to Group 2]
#' 4 := Grade 12 or GED      [Renamed to Group 3]
#' 5 := 1-3 Years of College [Renamed to Group 4]
#' 6 := 4+ Years of College  [Renamed to Group 5]

# Preprocessing Education Groups by Combining 1 and 2
diab <- diab %>% mutate(
  Education = case_when(
    Education %in% c(1,2) ~ "Middle or Less",
    Education == 3 ~ "Some High",
    Education == 4 ~ "High School Graduate",
    Education == 5 ~ "Some College",
    Education == 6 ~ "College Graduate"
  ),
  Diabetes_binary = factor(x = Diabetes_binary, levels = c(0,1), labels = c("No_Diabetes", "Diabetes")),
  Sex = factor(x = Sex, levels = c(0,1), labels = c("Female", "Male")),
  DiffWalk = factor(x = DiffWalk, levels = c(0,1), labels = c("No", "Yes")),
  GenHlth = factor(x = GenHlth, levels = 1:5,
                   labels = c("Excellent", "Very Good", "Good", "Fair", "Poor")),
  NoDocbcCost = factor(NoDocbcCost, levels = c(0,1), labels = c("No", "Yes")),
  AnyHealthcare = factor(AnyHealthcare, levels = c(0,1), labels = c("No", "Yes")),
  HvyAlcoholConsump = factor(HvyAlcoholConsump, levels = c(0,1), labels = c("No", "Yes")),
  HighBP = factor(HighBP, levels = c(0,1), labels = c("No", "Yes")),
  HighChol = factor(HighChol, levels = c(0,1), labels = c("No", "Yes")),
  CholCheck = factor(CholCheck, levels = c(0,1), labels = c("No", "Yes")),
  Smoker = factor(Smoker, levels = c(0,1), labels = c("No", "Yes")),
  Stroke = factor(Stroke, levels = c(0,1), labels = c("No", "Yes")),
  HeartDiseaseorAttack = factor(HeartDiseaseorAttack, levels = c(0,1), labels = c("No", "Yes")),
  PhysActivity = factor(PhysActivity, levels = c(0,1), labels = c("No", "Yes")),
  Fruits = factor(Fruits, levels = c(0,1), labels = c("No", "Yes")),
  Veggies = factor(Veggies, levels = c(0,1), labels = c("No", "Yes")),
  Age = factor(Age, levels = c(1:14),
               labels = c("18-24","25-29","30-34","35-39","40-44","45-49","50-54",
                          "55-59","60-64","65-69","70-74","75-79","80+",NA)),
  Income = factor(Income, levels = c(1:9)),
  PhysHlth = factor(PhysHlth, levels = c(0:30)),
  MentHlth = factor(MentHlth, levels = c(0:30))
)

diab_subset <- diab %>% filter(Education == params$Education)
diab_subset
```

    ## # A tibble: 9,478 × 22
    ##    Diabetes_binary HighBP HighChol CholCheck   BMI Smoker Stroke
    ##    <fct>           <fct>  <fct>    <fct>     <dbl> <fct>  <fct> 
    ##  1 No_Diabetes     Yes    No       Yes          27 No     No    
    ##  2 No_Diabetes     Yes    No       Yes          33 Yes    No    
    ##  3 Diabetes        Yes    Yes      Yes          24 Yes    No    
    ##  4 No_Diabetes     Yes    Yes      Yes          24 Yes    No    
    ##  5 No_Diabetes     Yes    No       Yes          22 Yes    No    
    ##  6 Diabetes        Yes    No       Yes          21 Yes    No    
    ##  7 No_Diabetes     No     No       No           24 Yes    No    
    ##  8 No_Diabetes     No     Yes      Yes          19 Yes    No    
    ##  9 No_Diabetes     No     No       Yes          23 Yes    No    
    ## 10 No_Diabetes     No     Yes      Yes          24 Yes    No    
    ## # ℹ 9,468 more rows
    ## # ℹ 15 more variables: HeartDiseaseorAttack <fct>, PhysActivity <fct>,
    ## #   Fruits <fct>, Veggies <fct>, HvyAlcoholConsump <fct>, AnyHealthcare <fct>,
    ## #   NoDocbcCost <fct>, GenHlth <fct>, MentHlth <fct>, PhysHlth <fct>,
    ## #   DiffWalk <fct>, Sex <fct>, Age <fct>, Education <chr>, Income <fct>

# Summarizations

In determining the evaluation of potentially significant variables for
predicting a response, the first phase is often getting an understanding
for the data. This section focused on **Exploratory Data Analysis** will
offer some automated graphs that describe the relationship between
variables of-interest while offering insight into how statisticians and
audiences outside of statistics might read the graph to glean
information.

## Univariate Visualizations of Categorical Variables

As the preprocessing for this dataset included the recasting of much of
the raw data into *factors*, we might be interested in the relative
frequencies of many of the levels of our categorical variables. From the
many, many graphs below, we can obtain some summary information about
the shape of our variables’ distributions and the similarities and
differences between the proportion of respondents who have Diabetes and
the proportions of respondents who have a certain income (see the
`Income` variable) or certain food intake (see the `Fruits` and
`Veggies` Variables).

``` r
cat_summ <- diab_subset %>% select(where(is.factor)) %>% 
  pivot_longer(cols = colnames(.)) %>%
  table() %>% as.data.frame(.) %>% mutate(
    isValidLevel = apply(., 1, function(x) {
  return( as.list(x)$value %in% unique(diab_subset[[as.list(x)$name]]) )
  })
  ) %>% filter(isValidLevel) %>% select(-isValidLevel) 

cat_plots <- lapply(unique(cat_summ$name), 
                    function(x) {
                      temp <- cat_summ %>% filter(name == x)
                      return(
                        ggplot(data = temp,
                               aes(x = value, y = Freq)) + 
                          geom_bar(
                            stat = "identity"
                        ) + labs(title = 
                                   paste0(temp$name),
                                 subtitle = paste0("N = ", nrow(temp)),
                                 y = "Count",
                                 x = "Response"
                                 ) +
                          theme_bw()
                      )
                    })
```

1

``` r
grid.arrange(grobs = cat_plots[1:4], nCol = 2)
```

![](some_high_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
grid.arrange(grobs = cat_plots[5:8], nCol = 2)
```

![](some_high_files/figure-gfm/unnamed-chunk-4-2.png)<!-- -->

``` r
grid.arrange(grobs = cat_plots[9:12], nCol = 2)
```

![](some_high_files/figure-gfm/unnamed-chunk-4-3.png)<!-- -->

``` r
grid.arrange(grobs = cat_plots[13:16], nCol = 2)
```

![](some_high_files/figure-gfm/unnamed-chunk-4-4.png)<!-- -->

``` r
grid.arrange(grobs = cat_plots[17:20], nCol = 2)
```

![](some_high_files/figure-gfm/unnamed-chunk-4-5.png)<!-- -->

## Two-Way Contingency Tables

Given the nature of the response ariable as binary, a two-way
contingency table naturally arises as a way to more numerically
visualize the relationship between response and predictor. In the below
tables, one may interpret each *cell* as the number of observations in
the dataset having response variable `Diabetes_binary` value either $0$
or $1$ and the answer to questions such as eating fruits (`Fruits`),
high cholesterol (`HighChol`), or age (`Age`).

``` r
tab <- table(diab_subset$Diabetes_binary,
             diab_subset$Fruits)
tab
```

    ##              
    ##                 No  Yes
    ##   No_Diabetes 3420 3762
    ##   Diabetes    1095 1201

``` r
tab1 <- table(diab_subset$Diabetes_binary,
              diab_subset$HighChol)
tab1
```

    ##              
    ##                 No  Yes
    ##   No_Diabetes 4027 3155
    ##   Diabetes     714 1582

``` r
tab2 <- table(diab_subset$Diabetes_binary,
              diab_subset$Age)
```

## Barplots of Response For Interesting Predictors

Barplots provide a visual of the distribution for our variables. For
example, below we see that more survey participants responded “Yes” to
high cholesterol (`HighChol`), we also see there is a higher prevalence
of diabetes in the high cholesterol group, indicating that high
cholesterol might also be a risk factor for diabetes. The other plots
display the proportion of survey participants that report eating
`Fruits`, and the age distribution in the sample.

``` r
g <- ggplot(data = diab_subset, aes(x = diab_subset$HighChol))
g + geom_bar(aes(fill = diab_subset$Diabetes_binary)) + theme_bw()
```

    ## Warning: Use of `diab_subset$Diabetes_binary` is discouraged.
    ## ℹ Use `Diabetes_binary` instead.

    ## Warning: Use of `diab_subset$HighChol` is discouraged.
    ## ℹ Use `HighChol` instead.

![](some_high_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
g2 <-ggplot(data = diab_subset, aes(x= diab_subset$Fruits))
g2 + geom_bar(aes(fill= diab_subset$Diabetes_binary)) + theme_bw()
```

    ## Warning: Use of `diab_subset$Diabetes_binary` is discouraged.
    ## ℹ Use `Diabetes_binary` instead.

    ## Warning: Use of `diab_subset$Fruits` is discouraged.
    ## ℹ Use `Fruits` instead.

![](some_high_files/figure-gfm/unnamed-chunk-6-2.png)<!-- -->

``` r
g3 <- ggplot(data = diab_subset, aes(x = diab_subset$Age))
g3 + geom_bar(aes(fill = diab_subset$Age)) + theme_bw()
```

    ## Warning: Use of `diab_subset$Age` is discouraged.
    ## ℹ Use `Age` instead.

    ## Warning: Use of `diab_subset$Age` is discouraged.
    ## ℹ Use `Age` instead.

![](some_high_files/figure-gfm/unnamed-chunk-6-3.png)<!-- -->

# Modeling

## Reproducible Train/Test Split

Consider the below code chunk to partition the data into *train* and
*test* datasets based on a 70-30 split.

``` r
# 70% <=> p = 0.7
indices <- createDataPartition(1:nrow(diab_subset), p = 0.7,list = F) 
train   <- diab_subset[indices,] 
test    <- diab_subset[-indices,]
```

## Discussion of Candidate Models and Related Items

### Log Loss vs Accuracy

Consider a vector $\pmb{Y} = (y_1,...,y_n)$ of $n$ true labels/classes
for $n$ data points in a testing set, and consider a classification
model attempting to identify data as belonging to a particular class.
Because the task of classification is a *supervised* one, wherein we
supply *labeled* features to a model, it stands to reason that we desire
a model that classifies well on both training data and unseen data. This
idea, referred to as **generalization**, implies that a model could be
trained to near-perfection on supplied observations but fail miserably
when applied in new scenarios!

To aid this process of generalization, statisticians introduce the
concept of *loss* into the model-training process; in essence, loss asks
the question \> How far off am I, the model, from ground truth?

To mathematically *quantify* loss and *minimize* it is as much of an art
as it is pure mathematics – consider questions such as

- **Are all misclassifications treated equally?** (Consider a false
  negative diagnosis to a cancer patient, versus a false positive for a
  light bulb factory.)

- **How should a model be penalized, or have its parameters adjusted,
  for a misclassification?** (This question lends itself to a discussion
  of algorithms such as **gradient descent** and **stochastic gradient
  descent**, wherein we generally want to avoid reaching a local minima
  of a loss function for which there are sets of \[hyper-\]parameters
  that yield better classification and generalization. Consider also the
  regression analog of this question yielded methods such as the LASSO
  (Tibshirani, 1996).)

For this discussion, we refer to loss functions $\mathcal{L}(y_i, p_i)$
as being **non-negative definite**, i.e.,
$\mathcal{L}(y_i, p_i)\geq 0 \forall y_i$.

Consider two of the more simpler functions used to evaluate
classification models, **log loss** (also known as cross-entropy loss)
and **accuracy**. In a binary setting, we define the log loss obtained
from predicting an observation to belong to the “positive” class with
probability $p_i \in (0,1)$ and true label $y_i \in \{0,1\}$ as
$$ \mathcal{L}(y_i, p_i) = -[y_i \ln(p_i) + (1-y_i)\ln(1-p_i)] $$ If we
adopted similar notation, the **accuracy** loss function, defined with
parameters $y_i \in \{0,\1}$ as the true label and
$\hat{y}_i \in \{0,1\}$ as the predicted label, wherein we might define
$$ \hat{y}_i = \begin{cases} 1 & p_i > c \\ 0 & p_i \leq c \end{cases} $$
such that we declare the model as predicting the observation belonging
to the positive class iff the probability at which it does so exceeds
some threshold $c \in [0,1]$ (i.e., $c = 0.5$). We then define accuracy
for the $i$-th observation as
$$ \mathcal{L}(y_i, \hat{y_i}) = \mathbb{I}(y_i = \hat{y}_i) $$ with
$\mathbb{I}$ the indicator function, such that
$$ \text{Accuracy} = \frac{1}{N}\sum_{i=1}^{N} \mathcal{L}(y_i, \hat{y}_i) $$

The question, naturally, is \> What’s the difference between log-loss
and accuracy?

The preference of the former lies in the harsher *penalization* by the
accuracy metric in incorrect cases. For example, consider a case where
the true label is $1$, a positive classification; even if the model
emits a positive classification with probability $p_i = c - \epsilon$
for some small $\epsilon > 0$, the accuracy metric regards this as
incorrect, no matter how close the model was to the truth! Because the
log loss function is differentiable, we can iteratively update the
hyperparameters of a classification model in the training process,
applying more drastic adjustments when the model predicts the incorrect
class with greater certainty.

In a more cross-validation perspective, wherein we might supply a
discretized grid of tuning parameters, we can better understand the
landscape of our multi-dimensional loss function by identifying which
parameter adjustments elicit the largest changes in log-loss! An
accuracy metric, as mentioned earlier, may fail to capture the more fine
discrepancies between sets of parameters. (Consider the multi-class loss
function below, where we now define $y_i \in \{0,1\}$ as representing
class $i \in \{1,2,...,n\}$ to be the true class.)

$$ \mathcal{L}(y_i,p_i) = -\sum_{i=1}^{n} y_i \ln(p_i) $$

**This** ability to adjust parameters and view the effects of these
adjustments is why log-loss is preferred to accuracy in many machine
learning applications as a means of evaluating the performance of
classification models!

### Logistic Regression Models

#### Description

For Logistic Regression, consider labels $Y \in \{0,1\}$, where these
values encode “failure/success” in a binary sense. Predictions
$\hat{Y} \in \{0,1\}$ by definition, and so we might model success
probability via
$$ P(Y|X) = \frac{e^{\beta_0 + \beta_1 x}}{1 + e^{\beta_0 + \beta_1 x}} $$
where the RHS is the **logistic function**. The **link function** in
logistic regression is given by
$$ g(\mu) = \beta_0 + \beta_1 x_1 + ... + \beta_p x_p  $$ where $\mu$ is
the mean for the set of $x$-values used. (Note $g(\mu) = \mu$ for
standard linear regression, which is called the *identity link* s.t. the
value predicted is mean response given $X$.)

However, there is no closed form solution used to fit $\beta_0,\beta_1$,
and so MLE often used to fit parameter. What instead we might do is
write the **logit function** or **log-odds function**
$$ \ln\Big(\frac{P(Y|X)}{1-P(Y|X)}\Big) = \beta_0 + \beta_1 X  $$ which
is linear in the parameters and offers a more intuitive explanation and
interpretation of coefficients (e.g., $\beta_1$ is now a change in
log-odds of success).

In a *multi-class* scenario, wherein $Y$ takes on more than two values,
and when $\pmb{X} = (1, x_1,...,x_p)$ is more than one predictor,
consider that
$$ P(Y|\pmb{X}) = \frac{e^{\beta_0 + \beta_1 x_1 + ... + \beta_p x_p}}{1 + e^{\beta_0 + \beta_1 x_1 + ... + \beta_p x_p}} = \frac{e^{\pmb{\beta}\pmb{X}}}{1 + e^{\pmb{\beta}\pmb{X}}} $$
and the logit function then becomes
$$ \ln\Big(\frac{P(Y|\pmb{X})}{1-P(Y|\pmb{X})}\Big) = \pmb{\beta}\pmb{X} $$
with
$\pmb{\beta} = \begin{bmatrix} \beta_0 & \beta_1 & ... & \beta_p \end{bmatrix}$.

#### Why Use in Classification?

With this type of data, we consider logistic regression as a candidate
modeling procedure because of a multitude of reasons, including

1.  **Ability to Handle Nonlinear Relationships**: Logistic regression
    is built on the idea that there could be a nonlinear relationship
    between the class and features; feature engineering can also easily
    be incorporated when parameterizing a logistic regression model with
    candidate predictors.

2.  **Ease of Interpretation**: The interpreted values from a logistic
    regression model are by nature the *probability of that observation
    belong to a positive class* (binary) *or to that particular class*
    (multi-class problem, wherein each model predicts for a single class
    and the predictions for each individual model are aggregated via
    maximums to obtain a single prediction for the observation).

#### Fitting of Candidate Logistic Regression Models

``` r
control <- trainControl(method="cv", number=5, classProbs=TRUE, 
                        summaryFunction=mnLogLoss)
logreg1 <- train(Diabetes_binary ~ .,
                 data= train %>% select(-Education),
                 family = "binomial",
                 method = "glmnet",
                 metric = "logLoss",
                 trControl = control
                 )
logreg2 <- train(Diabetes_binary ~ AnyHealthcare + 
                 GenHlth + MentHlth + PhysHlth + AnyHealthcare*GenHlth + Smoker,
                 data=train, 
                 family = "binomial",
                 method = "glmnet",
                 metric = "logLoss",
                 trControl = control)
logreg3 <- train(Diabetes_binary ~ BMI + Age + HighChol +
                 Fruits + Veggies + Sex + Age*Sex + HighChol*Sex + BMI*Sex,
                 data=train, 
                 family = "binomial",
                 method = "glmnet",
                 metric = "logLoss",
                 trControl = control)
```

In a comparison of the logsitic regression models based on the logLoss
metric, we see the results below at the best hyperparameters for each
individual model. The models are then compared based on logLoss to
determine the candidate logistic regression model, stored in
`candidateLRModel` below.

``` r
logregResults <- rbind(
  logreg1$results[which.min(logreg1$results$logLoss),],
  logreg2$results[which.min(logreg2$results$logLoss),],
  logreg3$results[which.min(logreg3$results$logLoss),]
)

logregResults
```

    ##   alpha       lambda   logLoss   logLossSD
    ## 8  1.00 0.0022908990 0.4765150 0.006153085
    ## 6  0.55 0.0133995479 0.5285024 0.001281079
    ## 1  0.10 0.0001949012 0.4983352 0.008063993

``` r
candidateLRModel <- list(logreg1, logreg2, logreg3)[[which.min(logregResults[,3])]]
```

### LASSO Regression Model

The lasso performs variable selection. It yields *sparse* models that
only involve a subset of the variables. The lasso is more resistant to
outliers than linear regression. The purpose of the lasso model is to
prevent overfitting.

``` r
control <- trainControl(method="cv", number=5, classProbs=TRUE, summaryFunction=mnLogLoss)

lassoFit <- train(Diabetes_binary ~ .,
                     data= train %>% select(-Education),
                     method = "glmnet",
                     metric = "logLoss",
                     trControl =  control)
```

The candidate LASSO model is *the* model fitted above, as we only
considered one model. Note the hyperparameters (i.e., `mtry`, the number
of parameters used) that resulted in the best fit are given below.

``` r
lassoFit$bestTune
```

    ##   alpha      lambda
    ## 8     1 0.002290899

### Classification Tree Model

A classification tree is a tree-based method that splits the data into
groups or regions.

``` r
control <- trainControl(method="cv", number=5, classProbs=TRUE, summaryFunction=mnLogLoss)
#set seed before training

classTreeFit <-train(Diabetes_binary ~ .,
                     data= train %>% select(-Education),
                     method = "rpart",
                     metric = "logLoss",
                     trControl =  control)
```

The candidate classification model model is *the* model fitted above, as
we only considered one model. Note the hyperparameters (i.e., `mtry`,
the number of parameters used) that resulted in the best fit are given
below.

``` r
lassoFit$bestTune
```

    ##   alpha      lambda
    ## 8     1 0.002290899

### Random Forest Model

#### Description

A random forest, as its name implies, involves two things – *trees*
(lots of them) and *randomness*. The idea behind a random forest model
is to fit *multiple* trees, as in bagging, but consider a **random
subset of predictors** in each tree fit.

By convention, the cardinality of this random subset depends usually on
the task at-hand – if $m$ denotes this cardinality and $p$ is the number
of predictors, then either $m = \sqrt{p}$ (classification) or $m = p/3$
(regression).

For *regression trees*… 1. Create a bootstrap sample (same size as
actual sample) via `sample.`

2.  Train a tree of the specified number of predictors from `1` – no
    pruning necessary. The prediction for a given set of $x$-values from
    this tree is then $\hat{y}^{*1}(x)$.

3.  Form $\hat{y}^{*j}(x)$ for $j = 1,..., B$ (e.g., $B = 1000$).

4.  Average to obtain
    $$ \hat{y}(x) = \frac{1}{B} \sum_{j=1}^{B} \hat{y}^{*j}(x) $$

For a *classification tree*… 1. Create a bootstrap sample (same size as
actual sample) via `sample.`

2.  Train a tree of the specified number of predictors on the sample
    from `1` – no pruning necessary. The prediction for a given set of
    $x$-values from this tree is then $\hat{y}^{*1}(x)$.

3.  Form $\hat{y}^{*j}(x)$ for $j = 1,..., B$ (e.g., $B = 1000$).

4.  (One option) Use the **majority vote** as the final classification
    prediction.

To *evaluate* random forest methods, we use the **prediction error**
(e.g., MSE), where for a test set having size $N$,
$$ \text{MSE} = \frac{1}{N} \sum_{i} (y_i - \hat{y}_i)^2 = \text{Bias}^2 + \text{Variance} $$

To *fit* bagging methods, use the `randomForest` package (bagging is
equivalent to RF with $m = p$). Relevant parameters include `mtry`
(number of predictors to try, either $\sqrt{p}$ or $p/3$ as above),
`ntree` (number of trees to fit), `importance = TRUE` (return variable
importance info such as `%IncMSE` and `IncNodePurity` through
`varImpPlot()` – more important variables having higher values here).

**Note**: Bootstrap samples will leave out some observations from
training, due to sampling w/ replacement! (On average, the method uses
around 2/3 of the data.) The resulting leftovers, the **Out-of-bag
(OOB)** observations, can be used for prediction! (To do this, use all
bootstrap models that did *not* use this particular data point in
training to predict it, and then appropriately average or obtain
majority votes to make final predictions). This results in a final
prediction error (OOB MSE) or classification error.

#### Advantage of Random Forest over Basic Classification Tree

The reason for utilizing random forests with is because if a really
strong predictor exists, every bootstrap tree will likely use it as a
first split, making the predictions more correlated (meaning a smaller
reduction in variance from aggregation). This is opposed with a basic
classification tree utilizes **all** predictors, which is not guaranteed
to learn the more nuanced relationships overshadowed by splitting on the
aforementioned more significant predictor.

#### Fitting of Random Forest Model

``` r
control <- trainControl(method="cv", number=5,
                        classProbs=TRUE, summaryFunction=mnLogLoss)
rfFit <- train(Diabetes_binary ~ ., 
               data = train %>% select(-Education),
               method = "rf",
               metric = "logLoss",
               trControl = control,
               tuneGrid = expand.grid(mtry = c(1,3,5,7,10,15)))
```

The candidate random forest model is *the* model fitted above, as we
only considered one model. Note the hyperparameters (i.e., `mtry`, the
number of parameters used) that resulted in the best fit are given
below.

``` r
rfFit$bestTune
```

    ##   mtry
    ## 5   10

### “New” Models

#### New Model 1: Naive Bayes Classifier

##### Description

**Naive Bayes Classifier** (NBC) models are a classification model that
utilize Bayesian statistical viewpoints to classify observations as
belonging to one of many classes. The *naivete* of this classifier comes
in the assumption of *independence* between all predictors, wherein the
model assumes that the probability of observing a particular observation
is then the convolution of probabilities of observing each particular
predictor value. In practice, however, variables can be **dependent** on
one another – this is often a question tackled in regression via
investigations into multicollinearity.

##### Fitting of Candidate Model

``` r
control <- trainControl(method="cv", number=5,
                        classProbs=TRUE, summaryFunction=mnLogLoss)
naiveBayes <- train(
  Diabetes_binary ~ .,
  data = train %>% select(-Education),
  method = "naive_bayes",
  trControl = control,
  metric = "logLoss",
  tuneGrid = expand.grid(
    laplace = c(0,1,10,100),
    usekernel = c(TRUE, FALSE),
    adjust = 1
  )
)
```

The candidate random forest model is *the* model fitted above, as we
only considered one model. Note the hyperparameters (i.e., `mtry`, the
number of parameters used) that resulted in the best fit are given
below.

``` r
naiveBayes$bestTune
```

    ##   laplace usekernel adjust
    ## 2       0      TRUE      1

#### New Model 2: Flexible Discriminant Analysis

#### Description

**Flexible Discriminant Analysis** models are a type of model that
extends traditional Linear Discriminate Analysis by allowing flexibility
to handle complex and class-specific covariate distributions. Flexible
Discriminant Analysis relaxes the assumption that the predictor
variables have a multivariate normal distribution within each class, so
it is more suitable for situations where the normality assumption may
not hold.

#### Fitting of Candidate Model

``` r
control <- trainControl(method="cv", number=5, classProbs=TRUE, 
                        summaryFunction=mnLogLoss)

fdaFit <- train(Diabetes_binary ~ .,
                     data= train %>% select(-Education),
                     method = "fda",
                     metric = "logLoss",
                     trControl =  control,
                     tuneGrid = expand.grid(
                        degree = c(1, 2, 3),       
                        nprune = c(5, 10, 15)      
                      ))
```

    ## Loading required package: earth

    ## Warning: package 'earth' was built under R version 4.3.2

    ## Loading required package: Formula

    ## Loading required package: plotmo

    ## Warning: package 'plotmo' was built under R version 4.3.2

    ## Loading required package: plotrix

    ## Warning: package 'plotrix' was built under R version 4.3.2

    ## Loading required package: TeachingDemos

    ## Warning: package 'TeachingDemos' was built under R version 4.3.2

# Final Model Selection

## Predicting the Model on Test Set

Below is a function that helps combine results from confusion matrices.

``` r
getAccSenSpec <- function(c) {
  return(c(c$overall["Accuracy"],
         c$byClass["Sensitivity"],
         c$byClass["Specificity"],
         c$overall["Kappa"]))
}
```

### Logistic Regression

``` r
logregPred <- as.numeric(predict(candidateLRModel, test,
                       type = "prob")[,2] > 0.5)
confMatLR <- confusionMatrix(as.factor(logregPred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
confMatLR
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2083  526
    ##          1  104  129
    ##                                           
    ##                Accuracy : 0.7783          
    ##                  95% CI : (0.7626, 0.7935)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.1374          
    ##                                           
    ##                   Kappa : 0.1929          
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.19695         
    ##             Specificity : 0.95245         
    ##          Pos Pred Value : 0.55365         
    ##          Neg Pred Value : 0.79839         
    ##              Prevalence : 0.23047         
    ##          Detection Rate : 0.04539         
    ##    Detection Prevalence : 0.08198         
    ##       Balanced Accuracy : 0.57470         
    ##                                           
    ##        'Positive' Class : 1               
    ## 

Consider the accuracy, sensitivity, and specificity (among other related
values) computed below. These values will be reported in a final
comparison.

``` r
logregResults <- sapply(list(confMatLR), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(logregResults) <- c("Logistic Regression")
temp <- data.frame(candidateLRModel$results[which.min(candidateLRModel$results$logLoss),"logLoss"])
colnames(temp) <- c("Logistic Regression")
logregResults <- rbind(logregResults, 
                      temp)
row.names(logregResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

### LASSO

``` r
lassoPred <- as.numeric(predict(lassoFit, test,
                       type = "prob")[,2] > 0.5)
confMatLASSO <- confusionMatrix(as.factor(lassoPred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
confMatLASSO
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2083  526
    ##          1  104  129
    ##                                           
    ##                Accuracy : 0.7783          
    ##                  95% CI : (0.7626, 0.7935)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.1374          
    ##                                           
    ##                   Kappa : 0.1929          
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.19695         
    ##             Specificity : 0.95245         
    ##          Pos Pred Value : 0.55365         
    ##          Neg Pred Value : 0.79839         
    ##              Prevalence : 0.23047         
    ##          Detection Rate : 0.04539         
    ##    Detection Prevalence : 0.08198         
    ##       Balanced Accuracy : 0.57470         
    ##                                           
    ##        'Positive' Class : 1               
    ## 

Consider the accuracy, sensitivity, and specificity (among other related
values) computed below. These values will be reported in a final
comparison.

``` r
lassoResults <- sapply(list(confMatLASSO), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(lassoResults) <- c("LASSO")
temp <- data.frame(lassoFit$results[which.min(lassoFit$results$logLoss),"logLoss"])
colnames(temp) <- c("LASSO")
lassoResults <- rbind(lassoResults, 
                      temp)
row.names(lassoResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

### Classification Tree

``` r
classTreePred <- as.numeric(predict(classTreeFit, test,
                       type = "prob")[,2] > 0.5)
confMatCT <- confusionMatrix(as.factor(classTreePred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
confMatCT
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2034  500
    ##          1  153  155
    ##                                           
    ##                Accuracy : 0.7702          
    ##                  95% CI : (0.7543, 0.7856)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.475           
    ##                                           
    ##                   Kappa : 0.2047          
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.23664         
    ##             Specificity : 0.93004         
    ##          Pos Pred Value : 0.50325         
    ##          Neg Pred Value : 0.80268         
    ##              Prevalence : 0.23047         
    ##          Detection Rate : 0.05454         
    ##    Detection Prevalence : 0.10837         
    ##       Balanced Accuracy : 0.58334         
    ##                                           
    ##        'Positive' Class : 1               
    ## 

Consider the accuracy, sensitivity, and specificity (among other related
values) computed below.

``` r
classTreeResults <- sapply(list(confMatCT), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(classTreeResults) <- c("Classification Tree")
temp <- data.frame(classTreeFit$results[which.min(classTreeFit$results$logLoss),"logLoss"])
colnames(temp) <- c("Classification Tree")
classTreeResults <- rbind(classTreeResults, 
                      temp)
row.names(classTreeResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

### Random Forest

``` r
rfPred <- as.numeric(predict(rfFit, test,
                       type = "prob")[,2] > 0.5)
confMatRF <- confusionMatrix(as.factor(rfPred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
confMatRF
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2105  554
    ##          1   82  101
    ##                                           
    ##                Accuracy : 0.7762          
    ##                  95% CI : (0.7604, 0.7914)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.2053          
    ##                                           
    ##                   Kappa : 0.1561          
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.15420         
    ##             Specificity : 0.96251         
    ##          Pos Pred Value : 0.55191         
    ##          Neg Pred Value : 0.79165         
    ##              Prevalence : 0.23047         
    ##          Detection Rate : 0.03554         
    ##    Detection Prevalence : 0.06439         
    ##       Balanced Accuracy : 0.55835         
    ##                                           
    ##        'Positive' Class : 1               
    ## 

Consider the accuracy, sensitivity, and specificity (among other related
values) computed below.

``` r
rfResults <- sapply(list(confMatRF), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(rfResults) <- c("Random Forest")
temp <- data.frame(rfFit$results[which.min(rfFit$results$logLoss),"logLoss"])
colnames(temp) <- c("Random Forest")
rfResults <- rbind(rfResults, 
                      temp)
row.names(rfResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

### Naive Bayes

``` r
naiveBayesPred <- as.numeric(predict(naiveBayes, test,
                       type = "prob")[,2] > 0.5)
confMatNBC <- confusionMatrix(as.factor(naiveBayesPred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
```

    ## Warning in confusionMatrix.default(as.factor(naiveBayesPred),
    ## as.factor(as.numeric(as.factor(test$Diabetes_binary)) - : Levels are not in the
    ## same order for reference and data. Refactoring data to match.

``` r
confMatNBC
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2187  655
    ##          1    0    0
    ##                                           
    ##                Accuracy : 0.7695          
    ##                  95% CI : (0.7536, 0.7849)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.5105          
    ##                                           
    ##                   Kappa : 0               
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.0000          
    ##             Specificity : 1.0000          
    ##          Pos Pred Value :    NaN          
    ##          Neg Pred Value : 0.7695          
    ##              Prevalence : 0.2305          
    ##          Detection Rate : 0.0000          
    ##    Detection Prevalence : 0.0000          
    ##       Balanced Accuracy : 0.5000          
    ##                                           
    ##        'Positive' Class : 1               
    ## 

``` r
nbcResults <- sapply(list(confMatNBC), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(nbcResults) <- c("Naive Bayes")
temp <- data.frame(naiveBayes$results[which.min(naiveBayes$results$logLoss),"logLoss"])
colnames(temp) <- c("Naive Bayes")
nbcResults <- rbind(nbcResults, 
                      temp)
row.names(nbcResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

### Flexible Discriminant Analysis

``` r
classFDAPred <- as.numeric(predict(classTreeFit, test,
                       type = "prob")[,2] > 0.5)
confMatFDA <- confusionMatrix(as.factor(classFDAPred), 
          as.factor(as.numeric(as.factor(test$Diabetes_binary)) - 1),
          positive = "1")
confMatFDA
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    0    1
    ##          0 2034  500
    ##          1  153  155
    ##                                           
    ##                Accuracy : 0.7702          
    ##                  95% CI : (0.7543, 0.7856)
    ##     No Information Rate : 0.7695          
    ##     P-Value [Acc > NIR] : 0.475           
    ##                                           
    ##                   Kappa : 0.2047          
    ##                                           
    ##  Mcnemar's Test P-Value : <2e-16          
    ##                                           
    ##             Sensitivity : 0.23664         
    ##             Specificity : 0.93004         
    ##          Pos Pred Value : 0.50325         
    ##          Neg Pred Value : 0.80268         
    ##              Prevalence : 0.23047         
    ##          Detection Rate : 0.05454         
    ##    Detection Prevalence : 0.10837         
    ##       Balanced Accuracy : 0.58334         
    ##                                           
    ##        'Positive' Class : 1               
    ## 

``` r
fdaResults <- sapply(list(confMatFDA), 
       function(x) {
         getAccSenSpec(x)
       })
colnames(fdaResults) <- c("Flexible Discriminant")
temp <- data.frame(fdaFit$results[which.min(fdaFit$results$logLoss),"logLoss"])
colnames(temp) <- c("Flexible Discriminant")
fdaResults <- rbind(fdaResults, 
                      temp)
row.names(fdaResults) <- c("Accuracy", "Sensitivity", "Specificity", "Kappa",
                             "Log Loss")
```

## Combining Results

``` r
allResults <- cbind(
  logregResults,
  lassoResults,
  classTreeResults,
  rfResults,
  nbcResults,
  fdaResults
)

names <- c("Logistic Regression",
           "LASSO",
           "Classification Tree",
           "Random Forest",
           "Naive Bayes Classifier",
           "FDA")

allResults
```

    ##             Logistic Regression     LASSO Classification Tree Random Forest
    ## Accuracy              0.7783251 0.7783251           0.7702322     0.7762139
    ## Sensitivity           0.1969466 0.1969466           0.2366412     0.1541985
    ## Specificity           0.9524463 0.9524463           0.9300412     0.9625057
    ## Kappa                 0.1929288 0.1929288           0.2046571     0.1561041
    ## Log Loss              0.4765150 0.4766376           0.5113418     0.4876274
    ##             Naive Bayes Flexible Discriminant
    ## Accuracy      0.7695285             0.7702322
    ## Sensitivity   0.0000000             0.2366412
    ## Specificity   1.0000000             0.9300412
    ## Kappa         0.0000000             0.2046571
    ## Log Loss      8.5407829             0.4783007

## Final Model Declaration

Based on the logLoss metric, we see that the Logistic Regression model
is the **best performing** model, minimizing the log-loss metric
compared to the other models tested. \`
