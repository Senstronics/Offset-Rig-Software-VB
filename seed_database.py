import os
import sqlite3

SOURCE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Example Configurations")
REPO_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_DB = r"C:\ProgramData\Senstronics\OffsetRig\offset_setup.db"

def clean_row(line):
    s = line.strip()
    if not s or s.startswith("#") or s.startswith(";"):
        return None
    return [item.strip() for item in s.split(",")]

def main():
    print("=== Seeding Offset Calibration SQLite Database ===")
    
    # Ensure target folder exists
    os.makedirs(os.path.dirname(TARGET_DB), exist_ok=True)
    
    # Connect to database (overwriting any previous run)
    if os.path.exists(TARGET_DB):
        try:
            os.remove(TARGET_DB)
        except Exception as e:
            print(f"Warning: Could not remove old database: {e}")
            
    conn = sqlite3.connect(TARGET_DB)
    cursor = conn.cursor()
    
    # 1. Create Schema
    cursor.execute("""
    CREATE TABLE product_ranges (
        prefix TEXT PRIMARY KEY,
        process_name TEXT NOT NULL,
        limit_voltage REAL DEFAULT 10.0,
        require_verification INTEGER DEFAULT 0,
        current_draw_lower REAL,
        current_draw_upper REAL
    );
    """)
    
    cursor.execute("""
    CREATE TABLE board_types (
        board_code TEXT PRIMARY KEY,
        board_symbol TEXT NOT NULL,
        require_stc INTEGER DEFAULT 0
    );
    """)
    
    cursor.execute("""
    CREATE TABLE connector_types (
        connector_code TEXT PRIMARY KEY,
        connector_name TEXT NOT NULL,
        is_four_pin INTEGER DEFAULT 0
    );
    """)
    
    cursor.execute("""
    CREATE TABLE wire_colours (
        colour_code TEXT PRIMARY KEY,
        colour_name TEXT NOT NULL
    );
    """)
    
    cursor.execute("""
    CREATE TABLE unions (
        union_code TEXT PRIMARY KEY,
        fitting_id INTEGER NOT NULL
    );
    """)
    
    cursor.execute("""
    CREATE TABLE cable_harness (
        channel_number INTEGER PRIMARY KEY,
        current_usage INTEGER DEFAULT 0,
        usage_limit INTEGER DEFAULT 10000
    );
    """)
    
    cursor.execute("""
    CREATE TABLE cable_mappings (
        cable_code TEXT PRIMARY KEY,
        channel_number INTEGER REFERENCES cable_harness(channel_number)
    );
    """)
    
    conn.commit()
    print("Schema created successfully.")
    
    # 2. Seed Board Types
    board_type_path = os.path.join(SOURCE_DIR, "Board Type.txt")
    if os.path.exists(board_type_path):
        with open(board_type_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 3:
                    cursor.execute("INSERT OR REPLACE INTO board_types (board_code, board_symbol, require_stc) VALUES (?, ?, ?)",
                                   (parts[0], parts[1], int(parts[2])))
        print("Seeded board_types.")
        
    # 3. Seed Connector Types
    conn_type_path = os.path.join(SOURCE_DIR, "Connector Type.txt")
    if os.path.exists(conn_type_path):
        with open(conn_type_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 3:
                    cursor.execute("INSERT OR REPLACE INTO connector_types (connector_code, connector_name, is_four_pin) VALUES (?, ?, ?)",
                                   (parts[0], parts[1], int(parts[2])))
        print("Seeded connector_types.")
        
    # 4. Seed Wire Colours
    colour_list_path = os.path.join(SOURCE_DIR, "Colour List.txt")
    if os.path.exists(colour_list_path):
        with open(colour_list_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 2:
                    cursor.execute("INSERT OR REPLACE INTO wire_colours (colour_code, colour_name) VALUES (?, ?)",
                                   (parts[0], parts[1]))
        print("Seeded wire_colours.")
        
    # 5. Seed Unions
    union_list_path = os.path.join(SOURCE_DIR, "Union List.txt")
    if os.path.exists(union_list_path):
        with open(union_list_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 2:
                    cursor.execute("INSERT OR REPLACE INTO unions (union_code, fitting_id) VALUES (?, ?)",
                                   (parts[0], int(parts[1])))
        print("Seeded unions.")
        
    # 6. Seed Cable Harness and Cable Mappings
    cable_usage_path = os.path.join(SOURCE_DIR, "Cable Usage.txt")
    if os.path.exists(cable_usage_path):
        with open(cable_usage_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 2:
                    # Skip the legacy text keys like UB, Z0
                    try:
                        chan = int(parts[0])
                        usage = int(parts[1])
                        cursor.execute("INSERT OR REPLACE INTO cable_harness (channel_number, current_usage) VALUES (?, ?)",
                                       (chan, usage))
                    except ValueError:
                        continue
        print("Seeded cable_harness.")
        
    cable_list_path = os.path.join(SOURCE_DIR, "Cable List.txt")
    if os.path.exists(cable_list_path):
        with open(cable_list_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 2:
                    try:
                        code = parts[0]
                        chan = int(parts[1])
                        # If the channel wasn't created in harness (e.g. 0 or not listed in usage), create it with 0 usage
                        cursor.execute("INSERT OR IGNORE INTO cable_harness (channel_number, current_usage) VALUES (?, 0)", (chan,))
                        cursor.execute("INSERT OR REPLACE INTO cable_mappings (cable_code, channel_number) VALUES (?, ?)",
                                       (code, chan))
                    except ValueError:
                        continue
        print("Seeded cable_mappings.")

    # 7. Seed Product Ranges (Merge non-standard routing + current draw overrides)
    product_dict = {} # prefix -> {process_name, limit_voltage, require_verification, current_draw_lower, current_draw_upper}
    
    # A. Load non-standard process routing (loaded from non-standard_processes.txt in repo directory)
    ns_path = os.path.join(REPO_DIR, "non-standard_processes.txt")
    if os.path.exists(ns_path):
        with open(ns_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 2:
                    prefix = parts[0]
                    proc = parts[1]
                    lim_volts = float(parts[2]) if len(parts) >= 3 else 10.0
                    req_ver = int(parts[3]) if len(parts) >= 4 else 0
                    product_dict[prefix] = {
                        "process_name": proc,
                        "limit_voltage": lim_volts,
                        "require_verification": req_ver,
                        "current_draw_lower": None,
                        "current_draw_upper": None
                    }
                    
    # B. Load current draw overrides (from current_draw.txt in Example Local folder)
    current_draw_path = os.path.join(SOURCE_DIR, "current_draw.txt")
    if os.path.exists(current_draw_path):
        with open(current_draw_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = clean_row(line)
                if parts and len(parts) >= 3:
                    prefix = parts[0]
                    lower_limit = float(parts[1])
                    upper_limit = float(parts[2])
                    if prefix in product_dict:
                        product_dict[prefix]["current_draw_lower"] = lower_limit
                        product_dict[prefix]["current_draw_upper"] = upper_limit
                    else:
                        product_dict[prefix] = {
                            "process_name": "Standard",
                            "limit_voltage": 10.0,
                            "require_verification": 0,
                            "current_draw_lower": lower_limit,
                            "current_draw_upper": upper_limit
                        }
                        
    # Insert combined product ranges
    for prefix, details in product_dict.items():
        cursor.execute("""
        INSERT OR REPLACE INTO product_ranges 
        (prefix, process_name, limit_voltage, require_verification, current_draw_lower, current_draw_upper)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (prefix, details["process_name"], details["limit_voltage"], details["require_verification"],
              details["current_draw_lower"], details["current_draw_upper"]))
              
    conn.commit()
    conn.close()
    print("Combined and seeded product_ranges.")
    print(f"SQLite seeding completed! Database is at: {TARGET_DB}")

if __name__ == "__main__":
    main()
