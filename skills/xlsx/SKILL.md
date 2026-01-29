# Excel (XLSX) Spreadsheet Skill

Claude Code supports comprehensive spreadsheet operations through the **xlsx** skill, enabling creation, editing, and analysis of Excel files (.xlsx, .xlsm, .csv, .tsv).

## Trigger
- When user needs Excel spreadsheet creation or editing
- Financial modeling or data analysis required
- Spreadsheet formulas and calculations needed
- Data import from CSV/TSV files

## Core Capabilities

**Primary functions include:**
- Creating new spreadsheets with formulas and formatting
- Reading and analyzing spreadsheet data
- Modifying existing files while preserving formulas
- Data visualization and analysis
- Formula recalculation and validation

## Key Requirements

**Formula Standards:**
- ZERO formula errors (#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?)
- Use Excel formulas rather than hardcoded values
- Dynamic and updateable through formulas

**Financial Modeling Conventions:**
- Color-coding: blue (inputs), black (formulas), green (internal links), red (external links)
- Yellow background for key assumptions
- Standard number formatting for currency, percentages, and multiples
- All assumptions in separate cells with formula references

**Workflow:**
- Leverages pandas for data analysis
- Uses openpyxl for formula/formatting work
- Requires `recalc.py` script to calculate formula values after file creation

## Use When

- Creating financial models
- Building data analysis spreadsheets
- Converting data to Excel format
- Generating reports with calculations
- Creating templates for recurring tasks
- Automating spreadsheet updates
