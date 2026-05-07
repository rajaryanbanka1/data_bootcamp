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