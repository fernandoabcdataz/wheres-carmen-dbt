import pandas as pd
import os

def process_and_export_excel(file_path, output_dir):
    # LOAD THE EXCEL FILE
    excel_file = pd.ExcelFile(file_path)
    
    # ITERATE THROUGH EACH SHEET AND SAVE AS CSV
    for sheet_name in excel_file.sheet_names:
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        
        # RENAME COLUMNS FOR SPECIFIC SHEETS IF NECESSARY
        if sheet_name == 'ASIA':
            df.columns = ['sighting', 'report_date', 'citizen', 'officer', 'latitude', 'longitude', 'city', 'nation', 'city_interpol', 'has_weapon', 'has_hat', 'has_jacket', 'behavior']
        elif sheet_name == 'EUROPE':
            df.columns = ['date_witness', 'date_filed', 'witness', 'agent', 'lat_', 'long_', 'city', 'country', 'region_hq', 'armed', 'chapeau', 'coat', 'observed_action']
        
        # ENSURE THE DATA IS PROPERLY ENCODED AND REMOVE UNEXPECTED CHARACTERS
        df = df.applymap(lambda x: x.encode('utf-8', 'ignore').decode('utf-8') if isinstance(x, str) else x)
        
        # CREATE OUTPUT PATH
        output_path = os.path.join(output_dir, f'{sheet_name}.csv')
        
        # SAVE TO CSV WITH UTF-8 ENCODING
        df.to_csv(output_path, index=False, encoding='utf-8')

    print("Conversion to CSV completed.")

if __name__ == "__main__":
    # DEFINE PATHS
    excel_file_path = 'carmen_sightings_20220629061307.xlsx'
    seeds_output_dir = '../carmen/seeds'
    
    # PROCESS AND EXPORT THE EXCEL FILE
    process_and_export_excel(excel_file_path, seeds_output_dir)