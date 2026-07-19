import pandas as pd
import os

os.makedirs('import', exist_ok=True)

print("Конвертація movies.dat...")
movies = pd.read_csv(
    'movies.dat', 
    sep='::', 
    engine='python', 
    encoding='latin-1', 
    header=None, 
    names=['movieId', 'title', 'genres']
)
movies.to_csv('import/movies.csv', index=False)

print("Конвертація users.dat...")
users = pd.read_csv(
    'users.dat', 
    sep='::', 
    engine='python', 
    encoding='latin-1', 
    header=None, 
    names=['userId', 'gender', 'age', 'occupation', 'zipCode']
)
users.to_csv('import/users.csv', index=False)

print("Конвертація ratings.dat...")
ratings = pd.read_csv(
    'ratings.dat', 
    sep='::', 
    engine='python', 
    encoding='latin-1', 
    header=None, 
    names=['userId', 'movieId', 'rating', 'timestamp']
)
ratings.to_csv('import/ratings.csv', index=False)

print("Конвертація успішно завершена! Файли збережено у папку import/")