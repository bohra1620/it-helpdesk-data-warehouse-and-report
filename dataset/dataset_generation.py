import pandas as pd
import random
import numpy as np
from datetime import datetime, timedelta

def generate_dirty_helpdesk_data(num_records=2000):
    # Base data pools
    agents = ['Alice Smith', 'Bob Jones', 'Charlie Brown', 'Diana Prince', 'Evan Wright']
    categories = ['Hardware', 'Software', 'Network', 'Access', 'Billing']
    ticket_types = ['Incident', 'Request']
    statuses = ['Closed', 'Resolved', 'Open', 'Pending']
    
    data = []
    start_date = datetime(2023, 1, 1)
    
    for i in range(num_records):
        # Generate base clean data
        ticket_id = f"TKT-{10000 + i}"
        agent = random.choice(agents)
        category = random.choice(categories)
        t_type = random.choice(ticket_types)
        status = random.choice(statuses)
        
        # Timestamps
        open_time = start_date + timedelta(days=random.randint(0, 360), hours=random.randint(8, 17))
        resolve_hours = random.randint(1, 120)
        close_time = open_time + timedelta(hours=resolve_hours) if status in ['Closed', 'Resolved'] else None
        
        # Feedback
        feedback_score = random.randint(1, 5) if status == 'Closed' else np.nan
        feedback_text = random.choice(["Great job", "Too slow", "Fixed my issue", "Unhelpful", "", ""]) if status == 'Closed' else ""

        # --- INJECTING "DIRTY" DATA ---
        
        # 1. Inconsistent string casing & typos
        if random.random() < 0.1:
            agent = agent.lower()
        elif random.random() < 0.1:
            agent = agent.upper()
            
        if random.random() < 0.15:
            t_type = random.choice(['incidnt', 'REQ', 'request ', ' Inc '])
            
        # 2. Logical errors (Close time before open time) - DO THIS FIRST
        if close_time and random.random() < 0.05:
            close_time = open_time - timedelta(days=random.randint(1, 5))
            
        # 3. Date format inconsistencies - DO THIS SECOND (Converts to string)
        if random.random() < 0.1:
            open_time = open_time.strftime('%m/%d/%Y %H:%M') # US format string
        elif random.random() < 0.1:
            open_time = open_time.strftime('%d-%m-%Y') # EU format string, missing time
            
        # 4. Out-of-bounds metrics / mixed data types
        resolution_hours_dirty = resolve_hours
        if random.random() < 0.05:
            resolution_hours_dirty = f"{resolve_hours} hrs" # String instead of int
        elif random.random() < 0.05:
            resolution_hours_dirty = -99 # Impossible negative
            
        # 5. Out-of-bounds feedback
        if not pd.isna(feedback_score) and random.random() < 0.05:
            feedback_score = random.choice([0, 6, 999])
            
        # 6. Null values in critical fields
        if random.random() < 0.05:
            category = np.nan
            
        data.append({
            'TicketID': ticket_id,
            'AgentName': agent,
            'TicketType': t_type,
            'Category': category,
            'Status': status,
            'OpenDateTime': open_time,
            'CloseDateTime': close_time,
            'ResolutionTimeHours': resolution_hours_dirty,
            'CustomerSatisfactionScore': feedback_score,
            'FeedbackComments': feedback_text
        })

    df = pd.DataFrame(data)
    
    # 7. Inject duplicate rows (simulating double-clicks or retry logic on ingestion)
    duplicates = df.sample(n=int(num_records * 0.03))
    df = pd.concat([df, duplicates], ignore_index=True)
    
    # Shuffle dataset
    df = df.sample(frac=1).reset_index(drop=True)
    
    return df

if __name__ == "__main__":
    print("Generating raw helpdesk data...")
    raw_df = generate_dirty_helpdesk_data(2000)
    output_file = "raw_helpdesk_tickets_bronze.csv"
    raw_df.to_csv(output_file, index=False)
    print(f"Dataset successfully generated and saved to {output_file}!")
    print(f"Total Rows: {len(raw_df)} (Includes ~3% duplicates)")