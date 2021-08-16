#!/usr/bin/env python
# coding: utf-8

# In[85]:


# Import Libraries

import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) #Adjusts the configurations of the plots created


# In[86]:


# Read the data

df = pd.read_csv(r'C:\Users\Shyam\Downloads\Portfolio Files\Movies\movies.csv')


# In[87]:


# Looking at the data

df.head()


# In[88]:


# Looking for missing data

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))


# In[89]:


# Looking at data types

df.dtypes


# In[90]:


# Filling NA values with the value 0

df = df.fillna(0)


# In[91]:


# Changing the data types of the columns from float to integer

df['budget'] = df['budget'].astype('int64')
df['gross'] = df['gross'].astype('int64')


# In[92]:


# Creating a new column (year released)

df['yearcorrect'] = df['released'].astype(str).str[:4]
df


# In[93]:


# Setting to display all the rows instead of just a few

pd.set_option('display.max_rows', None)


# In[94]:


# Sorting values in ascending order by gross

df = df.sort_values(by=['gross'], inplace = False, ascending = False)
df


# In[95]:


# remove duplicates

df['company'].drop_duplicates()


# In[96]:


# Budget will have a high correlation
# Company will have a high correlation


# In[97]:


# Scatter plot with budget and gross revenue

plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Film Budget')
plt.show()


# In[98]:


# Regression plot
# Plotting budget vs gross 

sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "red"}, line_kws={"color" : "blue"})


# In[99]:


# Looking at correlations in figures
# Pearson method

df.corr(method = 'pearson')


# In[100]:


# Kendall method

df.corr(method = 'kendall')


# In[101]:


# Spearman method

df.corr(method = 'spearman')


# In[102]:


# Creating a correlation matrix

correlation_matrix = df.corr(method = 'pearson')
sns.heatmap(correlation_matrix, annot = True)
plt.title = ('Correlation matrix for numeric features')
plt.xlabel = ('Movie features')
plt.ylabel = ('Movie features')
plt.show()


# In[106]:


# Converting string values to numeric
# Mainly for converting Company names to numeric

df_numerized = df

for col_name in df_numerized. columns:
    if (df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
        
df_numerized


# In[107]:


# Creating a correlation matrix using the new numerized data 

correlation_matrix = df_numerized.corr(method = 'pearson')
sns.heatmap(correlation_matrix, annot = True)
plt.title = ('Correlation matrix for numeric features')
plt.xlabel = ('Movie features')
plt.ylabel = ('Movie features')
plt.show()


# In[108]:


# Looking at the corralation without the correlation matrix

df_numerized.corr()


# In[109]:


# Ranking fields with the highest correlation

correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack()
corr_pairs


# In[114]:


# Sorting the correlation in pairs in descending order (highest on top)

sorted_pairs = corr_pairs.sort_values(ascending = False)
sorted_pairs


# In[115]:


# Filtering high correlations greater than 0.5

high_corr = sorted_pairs[(sorted_pairs) > 0.5]
high_corr


# In[ ]:




