from fastapi import FastAPI, HTTPException
import requests
from typing import Optional

app = FastAPI()

API_KEY = 'da1936f9265949119c070f5283b4081a'  # Thay thế 'your_newsapi_key' bằng API key của bạn
NEWSAPI_URL = 'https://newsapi.org/v2/top-headlines'

@app.get("/")
async def read_data():
     return "Hello"

@app.get("/news")
def get_news(country: Optional[str] = 'us', category: Optional[str] = None):
    params = {
        'apiKey': API_KEY,
        'country': country
    }
    if category:
        params['category'] = category
    
    response = requests.get(NEWSAPI_URL, params=params)
    
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.json())
    
    return response.json()




