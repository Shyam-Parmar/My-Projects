#!/usr/bin/env python
# coding: utf-8

# In[104]:


# Load Libraries
import pandas as pd
import numpy as np
import seaborn as sns
import pydotplus
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib
from pandas import read_csv
from pandas.plotting import scatter_matrix
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression as lm
from sklearn import metrics
from sklearn.preprocessing import PolynomialFeatures
from sklearn import linear_model
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import export_graphviz
from sklearn.metrics import plot_confusion_matrix
from six import StringIO  
from IPython.display import Image  


# In[36]:


# Load Dataset
df = read_csv("C:/Users/Shyam/Downloads/diabetes.csv")
df.head()


# In[37]:


# Summary Of The Data
# Shape 
print(df.shape)

# Descriptions
print(df.describe())


# In[38]:


# Clean The Dataset
# Check For Missing Values
for column in df.columns:
    pct_missing = np.mean(df[column].isnull())
    print('{} - {}%'.format(column, round(pct_missing*100)))


# In[39]:


# Rename Columns
new_names = {'BloodPressure' : 'BP',
             'SkinThickness' : 'Skin',
             'DiabetesPedigreeFunction' : 'Pedigree'}
df.rename(columns=new_names, inplace=True)

df.head()


# In[47]:


## Histograms for all columns
for i in df.columns:
    plt.hist(df[i])
    plt.title(i)
    plt.show()


# In[44]:


# Generate Visualization
# Histograms
df.hist(alpha = 0.5, figsize=(20, 10))
plt.tight_layout()
plt.show()


# In[46]:


# Box And Whisker Plot
df.plot(figsize = (20, 10), kind='box', subplots=True, layout=(3,3), sharex=False, sharey=False)
plt.show()


# In[8]:


# Pair Plot
sns.pairplot(df)
plt.show()


# In[48]:


## Correlation
print(df.corr())
sns.heatmap(df.corr())


# In[49]:


# Compare diabetes outcome to the rest of the features
pd.pivot_table(df, index = 'Outcome', values = ['Pregnancies','Glucose','BP','Skin',
                                                'Insulin','BMI','Pedigree', 'Age'])


# In[94]:


# Split into labels and features
# outcome is the label and the rest of the data are the features
feature_cols = ['Pregnancies','Glucose','BP','Skin','Insulin','BMI','Pedigree', 'Age']
x = df[feature_cols]
y = df.Outcome

x.head(10)


# In[95]:


# Train/Test The Dataset using the 80/20 sample
x_train, x_test,y_train,y_test = train_test_split(x,y,test_size =0.3, random_state = 1)


# In[96]:


# Training dataset shape
x_train.shape


# In[97]:


# Training dataset 
x_train.head()


# In[98]:


# Create a decision tree, classifier and predict the respose for the test dataset
clf = DecisionTreeClassifier()
clf = clf.fit(x_train,y_train)
y_pred = clf.predict(x_test)


# In[99]:


# Verify Model Accuracy 
# how often is the classifier correct?
print("Accuracy:",metrics.accuracy_score(y_test, y_pred))


# In[101]:


# Visualize the decision tree
dot_data = StringIO()
export_graphviz(clf, out_file = dot_data,  
                filled = True, rounded = True,
                special_characters = True,feature_names = feature_cols, class_names = ['0','1'])
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
graph.write_png('diabetes.png')
Image(graph.create_png())


# In[102]:


# Optimizing the decision tree
# Create Decision Tree classifer object
clf = DecisionTreeClassifier(criterion="entropy", max_depth=3)

# Train Decision Tree Classifer
clf = clf.fit(x_train,y_train)

# Predict the response for test dataset
y_pred = clf.predict(x_test)

# Verify Model Accuracy, how often is the classifier correct?
print("Accuracy:", metrics.accuracy_score(y_test, y_pred))


# In[103]:


# Visualize the decision tree
dot_data = StringIO()
export_graphviz(clf, out_file=dot_data,  
                filled=True, rounded=True,
                special_characters=True, feature_names = feature_cols,class_names=['0','1'])
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
graph.write_png('diabetes.png')
Image(graph.create_png())


# In[107]:


plot_confusion_matrix(clf, x_test, y_test)  
plt.title('Outcome')
plt.show() 

