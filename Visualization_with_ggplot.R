library(datasets)
# Load Data
data("mtcars")
# View first 5 rows
head(mtcars, 5)

# Load ggplot package
library(ggplot2)
# Create a scatterplot of displacement (disp) and miles per gallon (mpg)
ggplot(aes(x=disp, y=mpg), data=mtcars) + geom_point()

# Add a title
ggplot(aes(x=disp, y=mpg), data=mtcars) + geom_point() + ggtitle("Displacement vs Miles per Gallon")

# Change axis names
ggplot(aes(x=disp, y=mpg), data=mtcars) + geom_point() + ggtitle("Displacement vs Miles per Gallon") + labs(x="Displacement", y="Miles per Gallon")

# Make vs a Factor
mtcars$vs <- as.factor(mtcars$vs)

# Create a boxplot of the distribution for v-shaped and straight engine
ggplot(aes(x=vs, y=mpg), data=mtcars) + geom_boxplot()

# Add colors to the boxplot
ggplot(aes(x=vs, y=mpg, fill=vs), data=mtcars) +
  geom_boxplot(alpha=0.3) +
  theme(legend.position="none")

# Create the histogram of weight
ggplot(aes(x=wt), data=mtcars) + geom_histogram(binwidth=0.5)

# Plot with ggplot and GGally
library(datasets)
data("iris")
View(iris)

library(GGally)
ggpairs(iris, mapping = ggplot2::aes(colour = Species))