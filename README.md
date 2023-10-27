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

4. **View Creation (WIP)**: To visualize the data in Tableau, you can create views based on the SQL queries you've executed. Please note that this part is a work in progress.

The project involves a comparative analysis of hospital discharge data from Germany and the United States over a ten-year period, from 2012 to 2021. The primary objective is to gain insights into the principal diagnoses recorded in hospitals in these two countries and understand any significant trends or variations in healthcare utilization.

Please note that setting up MySQL and running these queries may require some level of expertise in database management. If you encounter any issues or need further assistance, consider referring to MySQL's official documentation or community resources for additional guidance.

 
## Findings
**Covid-19:**
As part of my analysis, it's essential to acknowledge the unique nature of COVID-19 and its impact on healthcare data collection. When the COVID-19 pandemic began, there was no specific ICD-10 code in place to identify this new disease. As a result, COVID-19-related data was initially dispersed among different placeholder codes and diagnostic groups, such as pneumonia.

| -       | ICD_10  | ICD_10_description                       | 2020   | 2019   | 2018   | 2017   | 2016   |
|---------|---------|------------------------------------------|--------|--------|--------|--------|--------|
| Germany | U71     | Covid-19                                 | -      | -      | -      | -      | -      |
| USA     | U71     | Covid-19                                 | 3.2927 | -      | -      | -      | -      |
| Germany | U4      | Severe acute respiratory syndrome [SARS] | 0.0009 | -      | -      | -      | -      |
| USA     | U4      | Severe acute respiratory syndrome [SARS] | -      | -      | -      | -      | -      |
| Germany | J00-J99 | Diseases of the respiratory system       | 6.0521 | 6.4538 | 6.6136 | 6.5231 | 6.3333 |
| USA     | J00-J99 | Diseases of the respiratory system       | 5.9028 | 7.6067 | 7.8383 | 7.9464 | 7.8105 |

My comparative analysis of hospital discharges between Germany and the United States (2016-2020) revealed a notable challenge regarding the diagnosis of COVID-19. The absence of a specific ICD-10 code for COVID-19 during the initial stages of the pandemic led to supposed data dispersion within broader diagnostic categories, including provisional codes in category U, "Diseases of uncertain etiology," and category J, "Diseases of the respiratory system."

In Germany, the official ICD-10 code U07.1, designated by the World Health Organization (WHO) for COVID-19, was not present in the source data for 2020 and 2021. It is likely that the diagnosis was categorized within the provisional codes in category U and/or category J.

In the United States, COVID-19 diagnosis codes were likely established earlier with a prevalence for covid at 3.3% in 2020.

In both countries, there was a slight decrease in diagnoses related to diseases of the respiratory system from their previous levels, with the US experiencing a drop from around 7.5-8% to 5.9%, and Germany showing a decline from approximately 6.5% to 6.0%.

This finding underscores the complexity of conducting a comparative analysis during a rapidly evolving health crisis, where changes in diagnostic coding and practices can significantly impact the interpretation of healthcare data. Further investigation into the reasons behind these diagnostic shifts is essential to gain a comprehensive understanding of the data trends observed in both countries.

The absence of a dedicated ICD-10 code for COVID-19 in the early stages of the pandemic posed challenges for data interpretation. While I have observed trends related to diseases of the respiratory system, the full extent of the impact of COVID-19 on hospital discharges remains uncertain in Germany due to the lack of specific ICD-10 codes in the source data for 2020 and 2021. Access to this missing information could potentially reshape my analysis.

---

**Z3800: Single liveborn infant, delivered vaginally:**  

| -       | ICD_10 | ICD_10_description                           | 2020    | 2019    | 2018    | 2017    | 2016    |
|---------|--------|----------------------------------------------|---------|---------|---------|---------|---------|
| Germany | Z38    | Liveborn infants according to place of birth | 3.0958  | 2.7630  | 2.8085  | 2.7764  | 2.7682  |
| USA     | Z38    | Liveborn infants according to place of birth | 10.7146 | 10.1320 | 10.2285 | 10.3784 | 10.6718 |

In the United States, around 10% of hospital discharges were associated with this diagnosis, reflecting a substantial proportion of vaginal deliveries.
In contrast, Germany reported notably lower numbers, with approximately 2-3% of hospital discharges linked to this "diagnosis".
This variance may stem from variations in healthcare practices, the availability of out-of-hospital childbirth facilities like "Geburtshaus" in Germany, and cultural preferences. 

---

**A41.9: Sepsis, unspecified organism:**

| -       | ICD_10 | ICD_10_description | 2020   | 2019   | 2018   | 2017   | 2016   |
|---------|--------|--------------------|--------|--------|--------|--------|--------|
| Germany | A41    | Other sepsis       | 0.3930 | 0.6568 | 0.6407 | 0.6142 | 0.6059 |
| USA     | A41    | Other sepsis       | 7.2134 | 6.2230 | 6.0526 | 5.6488 | 5.1295 |

In the United States, this diagnosis accounted for approximately 5-7% of all hospital discharges, indicating a relatively high incidence of sepsis cases. This high prevalence may suggest delayed medical intervention, potentially due to healthcare access issues.

In contrast, Germany reported a much lower occurrence, with only about 0.4-0.6% of hospital discharges linked to this diagnosis.

This significant divergence may be associated with disparities in healthcare access, where individuals in the United States may delay seeking medical attention due to insurance-related concerns. Consequently, infections may progress to life-threatening sepsis, necessitating hospitalization. Further investigation into healthcare policies, accessibility to medical care, and patient behaviors could shed light on the observed differences.

---

My analysis of hospital discharges in Germany and the United States from 2016 to 2020 reveals an interesting trend related to the prevalence of diabetes, including both type 1 and type 2.

**Diabetes Mellitus:**

| -       | ICD_10  | ICD_10_description | 2020   | 2019   | 2018   | 2017   | 2016   |
|---------|---------|--------------------|--------|--------|--------|--------|--------|
| Germany | E10-E14 | Diabetes mellitus  | 0.9710 | 1.0083 | 1.0258 | 1.0288 | 1.0341 |
| USA     | E10-E14 | Diabetes mellitus  | 2.0497 | 1.9935 | 1.9209 | 1.8497 | 1.6331 |

In the United States, I observed a slight increase in the prevalence of diabetes cases, rising from approximately 1.6% in 2016 to 2% in 2020. This indicates a higher number of individuals receiving treatment for diabetes during this period.

In contrast, Germany's data suggests that the prevalence of diabetes cases remained relatively stable, hovering around 1% over the same period.

It's important to note that these figures reflect the number of individuals who received treatment for diabetes in hospitals, rather than the total number of individuals affected by the disease. While this data provides insights into healthcare utilization, it may not directly represent the overall prevalence of diabetes in each country.

---

The analysis is ongoing, and findings will be updated in this README as they become available. Insights may include trends in principal diagnoses, differences in healthcare utilization, and other noteworthy observations.

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
 
## License
This project is licensed under the MIT License. See the [LICENSE](license.txt) file for details.
