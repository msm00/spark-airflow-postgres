import pandas as pd
import re
import psycopg2
from datetime import datetime

def remove_accents(text):
    """Odstraní diakritiku z textu"""
    mapping = {
        'á': 'a', 'č': 'c', 'ď': 'd', 'é': 'e', 'ě': 'e', 'í': 'i',
        'ň': 'n', 'ó': 'o', 'ř': 'r', 'š': 's', 'ť': 't',
        'ú': 'u', 'ů': 'u', 'ý': 'y', 'ž': 'z'
    }
    
    result = text.lower()
    for acc, nonacc in mapping.items():
        result = result.replace(acc, nonacc)
    
    return result

def create_username(first_name, last_name):
    """Vytvoří username z jména a příjmení"""
    username = f"{remove_accents(first_name)}_{remove_accents(last_name)}"
    username = re.sub(r'\s+', '_', username)
    return username.lower()

# Načtení dat
df = pd.read_csv('data/sample_data.csv')
print(f"Načteno {len(df)} záznamů z CSV souboru")

# Transformace dat
df['username'] = df.apply(lambda row: create_username(row['first_name'], row['last_name']), axis=1)
df['created_at'] = datetime.now()
df['updated_at'] = datetime.now()

# Výběr a přejmenování sloupců
transformed_df = df[['first_name', 'last_name', 'email', 'username', 'created_at', 'updated_at']]

# Zobrazení transformovaných dat
print("Transformovaná data:")
print(transformed_df)

# Uložení do PostgreSQL
try:
    conn = psycopg2.connect(
        host="postgres",
        database="etl_db",
        user="postgres",
        password="postgres",
        port="5432"
    )
    
    cursor = conn.cursor()
    
    # Vypsat hodnoty pro vložení
    for _, row in transformed_df.iterrows():
        insert_query = """
        INSERT INTO users_transformed (first_name, last_name, email, username, created_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            row['first_name'], 
            row['last_name'], 
            row['email'], 
            row['username'],
            row['created_at'],
            row['updated_at']
        ))
    
    conn.commit()
    print(f"Data byla úspěšně uložena do tabulky users_transformed v PostgreSQL")
    
    # Zobrazení dat z databáze
    cursor.execute("SELECT * FROM users_transformed")
    rows = cursor.fetchall()
    
    print("\nData uložená v PostgreSQL:")
    for row in rows:
        print(row)
        
except Exception as e:
    print(f"Chyba při ukládání do PostgreSQL: {e}")
finally:
    if 'conn' in locals():
        conn.close() 