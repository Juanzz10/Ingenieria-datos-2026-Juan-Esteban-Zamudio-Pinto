import pandas as pd
import sqlite3

# -------- Configuración --------
INPUT_EXCEL = "1000-Registros-de-ventas.xlsx"
OUTPUT_DB = "ventas.db"
TABLE_NAME = "ventas"

# -------- Función de clasificación --------
def clasificar(total_venta):
    if total_venta > 500:
        return "Alta"
    elif total_venta >= 100:
        return "Media"
    else:
        return "Baja"

def main():
    print("ETL: Inicio del proceso")

    # ===== 1. EXTRACCIÓN =====
    print(f"Leyendo archivo Excel: {INPUT_EXCEL}")
    df = pd.read_excel(INPUT_EXCEL)

    print("\nDatos originales:")
    print(df.head())

    # ===== 2. TRANSFORMACIÓN =====
    print("\nTransformando datos...")

    # Normalizar nombres de columnas
    df.columns = [c.strip().lower() for c in df.columns]

    # Eliminar duplicados
    df = df.drop_duplicates()

    # Asegurar tipos numéricos
    df["precio unitario"] = pd.to_numeric(df["precio unitario"], errors="coerce")
    

    # Convertir fecha
    df["fecha pedido"] = pd.to_datetime(df["fecha pedido"], errors="coerce")
    df["fecha envío"] = pd.to_datetime(df["fecha envío"], errors="coerce")

    # Eliminar filas incompletas
    df = df.dropna(subset=["id cliente", "tipo de producto", "precio unitario", "unidades"])

    # Estandarizar texto
    df["id cliente"] = df["id cliente"].str.title().str.strip()
    df["tipo de producto"] = df["tipo de producto"].str.upper().str.strip()
    df["zona"] = df["zona"].astype(str).str.upper().str.strip()

    # Calcular total de la venta
    df["importe venta total"] = df["precio unitario"] * df["unidades"]

    # Clasificar ventas
    df["categoria_venta"] = df["importe venta total"].apply(clasificar)

    print("\nDatos transformados:")
    print(df.head())

    # ===== 3. LOAD =====
    print(f"\nCargando datos en la base de datos: {OUTPUT_DB}")
    conn = sqlite3.connect(OUTPUT_DB)
    df.to_sql(TABLE_NAME, conn, if_exists="replace", index=False)
    conn.close()

    print("Carga finalizada ✅")

    # Verificación rápida
    conn = sqlite3.connect(OUTPUT_DB)
    preview = pd.read_sql(f"SELECT * FROM {TABLE_NAME} LIMIT 5", conn)
    print("\nVerificación de datos cargados:")
    print(preview)
    conn.close()

    print("ETL: Fin del proceso")

if __name__ == "__main__":
    main()
