# Principal_diagnoses_DE_US
Comparative analysis of hospital discharges from Germany and the US (2012 to 2021).

## Overview
This project focuses on the comparative analysis of hospital discharge data from Germany and the United States over a ten-year period, from 2012 to 2021. The primary objective is to gain insights into the principal diagnoses recorded in hospitals in these two countries and understand any significant trends or variations in healthcare utilization. 

## Rationale for Country Selection
The choice to focus on hospital discharges in Germany and the United States for this comparative analysis is driven by several compelling reasons:

### Personal Connection
Germany, being my home country, holds a personal interest for me. Analyzing healthcare trends and principal diagnoses in my home nation adds an extra layer of relevance to this project.

### Contrasting Healthcare Systems
The United States offers a fascinating contrast to Germany due to its healthcare system. Unlike the comprehensive universal healthcare coverage in Germany, the U.S. healthcare system operates differently, with no general healthcare insurance. This difference can significantly impact the reasons people visit hospitals and the nature of principal diagnoses recorded.

### Lifestyle and Health Factors
Principal diagnoses often reflect the overall health and lifestyle of a population. The United States has been widely portrayed in the media for certain health challenges, including issues related to obesity, diabetes, and other endocrine disorders. Analyzing principal diagnoses may shed light on how lifestyle factors manifest in healthcare data.

### COVID-19 Impact
This project's timeframe, spanning from 2012 to 2021, covers a critical period in healthcare history. The emergence of COVID-19 in Europe and the United States during this timeframe presents a unique opportunity to observe how a significant global health event can impact principal diagnoses and healthcare utilization.

By comparing and contrasting these two countries, I aim to gain valuable insights into the dynamics of hospital discharges, healthcare trends, and the broader health landscape in both Germany and the United States.

## Additional Datasets: Length of Hospital Stays (WIP)

To enhance the comprehensiveness of this analysis and gain deeper insights into the healthcare landscape, we plan to incorporate additional datasets that provide information on the length of hospital stays for different diagnoses. This addition is motivated by personal experiences and a desire to explore how the duration of hospitalization varies across different health conditions.

### Dataset Sources
I am actively seeking and evaluating datasets that include information on hospitalization duration in both Germany and the United States. These datasets will help us understand not only the prevalence of specific diagnoses but also the associated healthcare resources and patient care practices.

### Personal Motivation
Personal experiences, such as witnessing individuals with heart surgery being discharged after a relatively short hospital stay, have underscored the significance of hospitalization duration. It has inspired me to delve deeper into this aspect of healthcare analytics and examine potential variations and trends related to different diagnoses.

I anticipate that the inclusion of this data will provide a more comprehensive view of healthcare utilization in both countries and contribute to a richer understanding of the factors influencing the length of hospital stays for various medical conditions.

As I acquire and integrate these additional datasets, I will update this README with the relevant information and insights.

## Data Sources and Structure
### Timeframes
- **German Data**: The dataset covers the period from 2012 to 2021, which serves as a comprehensive dataset for a general analysis of hospital discharges in Germany. The extended timeframe allows for in-depth insights into long-term trends.

- **US Data**: For the comparative analysis of hospital discharges between Germany and the United States, the dataset timeframe was narrowed down to match the available US data, specifically from 2016 to 2020. This focused timeframe enables direct comparisons between the two countries and their healthcare utilization during the same period.

### Data Structure
The source data for this project exhibit slight structural differences:

- **German Data**: The German dataset includes approximately 2,000 ICD-10 codes and also groups some of these codes. As a result, specific handling in SQL queries is required to prevent counting entries multiple times, particularly when dealing with grouped codes.

- **US Data**: In contrast, the US dataset is more extensive, listing around 70,000 ICD-10 codes. Additionally, it employs weighted record counts to reflect national estimates of inpatient stays from community hospitals in the United States. The "NIS: Weighted N for DX1" column from Table 2 in the National (Nationwide) Inpatient Sample (NIS) Database Documentation was utilized. DX1 represents the principal ICD-10-CM diagnosis, which is the primary condition responsible for the patient's hospital admission.

The differences in data structure, timeframes, and methodologies used for counting and weighting records contribute to the richness of this comparative analysis, allowing for a comprehensive examination of principal diagnoses in both Germany and the United States.

## Data Analysis and MySQL Database Setup

This section covers the key steps involved in both data analysis and setting up the MySQL database for those who plan to reproduce this analysis. If you're already familiar with MySQL or have a running instance, you can skip the MySQL setup instructions.

1. **Install MySQL**: If you don't have MySQL installed, you can download it from the [official MySQL website](https://dev.mysql.com/downloads/mysql/). Follow the installation instructions for your operating system.

2. **Database Import**: After installing MySQL, you will need to import the data from the provided sources. This can be achieved using the MySQL command-line interface or a graphical tool like popSQL.

3. **SQL Queries**: The SQL queries used in this analysis are available in the [project's code repository](principal_diagnosis.sql). You can run these queries against your MySQL database to extract and transform the data.

4. **View Creation**: To visualize the data in Tableau, you can create views based on the SQL queries you've executed. Please note that this part is a work in progress.

The project involves a comparative analysis of hospital discharge data from Germany and the United States over a ten-year period, from 2012 to 2021. The primary objective is to gain insights into the principal diagnoses recorded in hospitals in these two countries and understand any significant trends or variations in healthcare utilization.

Please note that setting up MySQL and running these queries may require some level of expertise in database management. If you encounter any issues or need further assistance, consider referring to MySQL's official documentation or community resources for additional guidance.

## References

### German Principal Diagnosis Data
- Source: Statistisches Bundesamt Ergebnis 23131-0001
- Description: "Krankenhauspatienten: Deutschland, Jahre, Hauptdiagnose ICD-10 (1-3-Steller Hierarchie)"
- [Access Data](https://www-genesis.destatis.de/genesis/online?operation=find&suchanweisung_language=de&query=23131-0001#abreadcrumb)

### German Population Size Data
- Source: Statista
- Description: "Bevölkerung - Zahl der Einwohner in Deutschland nach relevanten Altersgruppen am 31. Dezember 2022"
- [Access Data](https://de.statista.com/statistik/daten/studie/2861/umfrage/entwicklung-der-gesamtbevoelkerung-deutschlands/)

### US Principal Diagnosis Data
- Source: Healthcare Cost & Utilization Project (HCUP)
- Description: "National (Nationwide) Inpatient Sample (NIS) Database Documentation"
- [Access Data](https://hcup-us.ahrq.gov/db/nation/nis/nisdbdocumentation.jsp)
- [Direct Link to Data](https://hcup-us.ahrq.gov/db/nation/nis/HCUP-NIS2016-2020-DXandPRfreqs.xlsx)

### US Population Size Data
- Source: United States Census Bureau
- Description: "National Demographic Data 2010 to 2020"
- [Access Data](https://www2.census.gov/programs-surveys/popest/tables/2010-2020/national/totals/)
  
## Findings
The analysis is ongoing, and findings will be updated in this README as they become available. Insights may include trends in principal diagnoses, differences in healthcare utilization, and other noteworthy observations.

## License
This project is licensed under the MIT License. See the [LICENSE](license.txt) file for details.
