# Blueprint: Loan Comparison App

## Overview

This application is designed to help Brazilian users compare different types of loans offered by various banks. It provides a platform to explore loan options and simulate specific loan scenarios to find the most suitable financial products. The user interface and all text are in Portuguese to cater to the target audience.

## Implemented Style, Design, and Features

This section documents the project's evolution.

### Version 1.6

*   **Accurate Rate Formatting:** Updated the percentage formatting in the `BankListScreen` to ensure all interest rates are displayed with a minimum of two decimal places, providing greater precision and clarity.

### Version 1.5

*   **Simulator Bug Fix:** Corrected a critical error in the loan simulator that was caused by recent data model changes. The calculation now correctly uses the `monthlyInterestRate`.
*   **Flexible Loan Terms:** The simulator has been enhanced to allow users to input the loan term in either "Months" or "Years," providing greater flexibility.
*   **Dynamic Calculation:** The payment calculation logic now intelligently handles both monthly and yearly terms, converting years to months to ensure the formula is always accurate.

### Version 1.4

*   **Comprehensive Rate Display:** The `BankListScreen` now displays both monthly and annual interest rates, giving users a more complete understanding of loan costs.
*   **Expanded Data Model:** The `Bank` model was updated to include both `monthlyInterestRate` and `yearlyInterestRate`, parsed directly from the BCB API.
*   **Advanced Sorting:** The sorting functionality on the `BankListScreen` was enhanced to allow users to rank banks by either their monthly or annual interest rates.

### Version 1.3

*   **Robust Date Logic:** The bank data API call now uses a more robust date calculation. It queries for data from 3 weeks ago and automatically adjusts the date to the previous Friday if it falls on a weekend, ensuring a valid weekday is always used.

### Version 1.2

*   **Real Bank Data:** The app now fetches real-time interest rate data for banks offering a specific loan type. The mock bank data has been completely removed.

### Version 1.1

*   **API Integration:** The app now fetches real loan type data from the official Brazilian Central Bank (BCB) API.

### Version 1.0

*   **Project Structure:** Standard Flutter project structure.
*   **Core Navigation & Routing:** `go_router` with a `BottomNavigationBar`.
*   **Theming:** Material 3 theme with light/dark modes using `provider`.
*   **Data Models & API Service:** Initial setup with mock data.
*   **Screens:** `ExplorerScreen`, `BankListScreen`, `SimulatorScreen`.
*   **Localization:** `intl` package for `pt_BR` formatting.

## Current Plan: Improve Data Formatting (v1.6)

The goal of this iteration is to improve the accuracy of the data presentation by fixing the formatting of interest rate percentages.

### Steps:

1.  **Update Formatting Logic:** Modify the `_formatRate` function in `lib/bank_list_screen.dart` to use a `NumberFormat` instance that enforces a minimum of two decimal digits.
2.  **Update Blueprint:** Document the formatting improvement for better data accuracy.