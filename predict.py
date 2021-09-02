import pandas as pd
import datetime as dt
import numpy as np

df = pd.read_csv('sphist.csv')
df['Date'] = pd.to_datetime(df['Date'])
df = df.sort_values('Date', ascending = True).reset_index(drop=True)
# current_date = dt.datetime.strptime('1950-12-26', "%Y-%m-%d")
def rolling_avg(dataframe, window):
    '''
    Finds the rolling average, given window to calculate from
    '''
    dataframe['day_{}_mean'.format(window)] = 0
    for i, row in dataframe.iterrows():
        if i > window:
            dataframe.loc[i,'day_{}_mean'.format(window)] = (dataframe.loc[i-window+1:i,'Close'].mean() + dataframe.loc[i-window+1:i, 'Open'].mean() + dataframe.loc[i-window+1:i, 'High'].mean() + dataframe.loc[i-window+1:i, 'Close'].mean())/window
        else:
            ''
    return dataframe

new_df = rolling_avg(df, 5)
new_df = rolling_avg(new_df, 30)
new_df = rolling_avg(new_df, 365)

new_df = new_df[new_df['Date'] > dt.datetime.strptime("1951-01-03", "%Y-%m-%d")]
new_df = new_df.dropna(axis=0)

train = new_df[new_df['Date'] < dt.datetime.strptime("2013-01-01", "%Y-%m-%d")]
test = new_df[new_df['Date'] > dt.datetime.strptime("2013-01-01", "%Y-%m-%d")]

def mean_absolute_error(predict, real):
    '''
    Calculate MAE from two series
    '''
    
    mae = np.sum(predict - real) / len(predict)
    return mae

from sklearn.linear_model import LinearRegression

X_train = train.drop(['Close','High','Low','Open','Volume','Adj Close','Date'], axis=1)
y_train = train['Close']
lr = LinearRegression()
lr.fit(X_train, y_train)

X_test = test.drop(['Close','High','Low','Open','Volume','Adj Close','Date'], axis=1)
y_test = test['Close']

predict = lr.predict(X_test)
mae = mean_absolute_error(predict, y_test)

print(mae)