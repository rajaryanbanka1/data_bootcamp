"""
import pandas as pd
from sqlalchemy import create_engine
import datetime

# 1. Connection String
# Format: postgresql://username:password@host:port/database
engine = create_engine('postgresql://postgres:admin123@localhost:5432/postgres')

def ingest_data():
    try:
        # 2. Simulate Extraction (Creating a DataFrame)
        data = {
            'user_id': ['USR_011', 'USR_012'],
            'product_id': [101, 105],
            'purchase_time': [datetime.datetime.now(), datetime.datetime.now()],
            'amount': [150.00, 500.00]
        }
        df = pd.DataFrame(data)

        # 3. Load to SQL (The 'append' mode adds to existing data)
        df.to_sql('transactions', engine, if_exists='append', index=False)
        print("✅ Data successfully ingested!")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    ingest_data()
"""


import os
import pandas as pd
import logging
from sqlalchemy import create_engine
from dotenv import load_dotenv

# 1. Load environment variables from .env file
load_dotenv()

# 2. Setup Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_db_engine():
    """Constructs the database engine using environment variables."""
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    host = os.getenv('DB_HOST')
    port = os.getenv('DB_PORT')
    db = os.getenv('DB_NAME')
    
    # Construct the connection string
    url = f"postgresql://{user}:{password}@{host}:{port}/{db}"
    return create_engine(url)

def ingest_data(df, table_name):
    try:
        if df.empty:
            logging.warning("No data to ingest.")
            return

        engine = get_db_engine()
        
        # Data Validation: Remove future dates (The 2099 logic)
        current_time = pd.Timestamp.now()
        df = df[df['purchase_time'] <= current_time]

        # Load data
        df.to_sql(table_name, engine, if_exists='append', index=False, chunksize=1000)
        logging.info(f"✅ Successfully ingested {len(df)} rows into {table_name}")

    except Exception as e:
        logging.error(f"❌ Pipeline Error: {e}")

if __name__ == "__main__":
    # Test Data with a 'dirty' entry (future date)
    test_df = pd.DataFrame({
        'user_id': ['USR_015', 'USR_999'],
        'product_id': [103, 101],
        'purchase_time': [pd.Timestamp.now(), pd.Timestamp('2099-01-01')],
        'amount': [300.00, 150.00]
    })
    
    ingest_data(test_df, 'transactions')